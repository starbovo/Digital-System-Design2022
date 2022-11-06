

`timescale 1ns/1ps


module cmd_parse(
  input             clk_rx,         // Clock input
  input             rst_clk_rx,     // Active HIGH reset - synchronous to clk_rx

  input      [7:0]  rx_data,        // Character to be parsed
  input             rx_data_rdy,    // Ready signal for rx_data
  // From Character FIFO
  input             char_fifo_full, // The char_fifo is full
  // To/From Response generator
  output reg        send_char_val,  // A character is ready to be sent
  output reg [7:0]  send_char,      // Character to be sent
  output reg        send_resp_val,  // A response is requested
  output reg [1:0]  send_resp_type, // Type of response - see localparams
  output reg [15:0] send_resp_data, // Data to be output
  input             send_resp_done, // The response generation is complete
  // to system
  output reg [31:0] bt_data32
);

//***************************************************************************
// Parameter definitions
//***************************************************************************
  parameter MAX_ARG_CH   = 8;    // Number of characters in largest set of args

  localparam [1:0]
     RESP_OK   = 2'b00,
     RESP_ERR  = 2'b01;
  // States for the main state machine
  localparam
     IDLE      = 3'b000,
     GET_ARG   = 3'b001,
     SEND_RESP = 3'b010;

   localparam
     CMD_W     = 7'h57,
     CMD_R     = 7'h52,
     CMD_N     = 7'h4e,
     CMD_P     = 7'h50,
     CMD_S     = 7'h53,
     CMD_n_l   = 7'h6e,
     CMD_p_l   = 7'h70,
     CMD_s_l   = 7'h73,
     CMD_G     = 7'h47,
     CMD_C     = 7'h43,
     CMD_H     = 7'h48;
//***************************************************************************
// Functions declarations
//***************************************************************************
  `include "clogb2.txt"
//***************************************************************************
// Reg declarations
//***************************************************************************
  reg [2:0]         state;    // State variable
  reg               old_rx_data_rdy; // rx_data_rdy on previous clock
  reg [4*MAX_ARG_CH-5:0]        arg_sav;  // All but last char of args 
  reg [clogb2(MAX_ARG_CH)-1:0]  arg_cnt;  // Count the #chars in an argument

//***************************************************************************
// Wire declarations
//***************************************************************************

  // Accept a new character when one is available, and we can push it into
  // the response FIFO. A new character is available on the FIRST clock that
  // rx_data_rdy is asserted - it remains asserted for 1/16th of a bit period.
  wire new_char = rx_data_rdy && !old_rx_data_rdy && !char_fifo_full; 

  
//***************************************************************************
// Tasks and Functions
//***************************************************************************

  // This function takes the lower 7 bits of a character and converts them
  // to a hex digit. It returns 5 bits - the upper bit is set if the character
  // is not a valid hex digit (i.e. is not 0-9,a-f, A-F), and the remaining
  // 4 bits are the digit
  function [4:0] to_val;
    input [6:0] char;
  begin
    if ((char >= 7'h30) && (char <= 7'h39)) // 0-9
    begin
      to_val[4]   = 1'b0;
      to_val[3:0] = char[3:0];
    end
    else if (((char >= 7'h41) && (char <= 7'h46)) || // A-F
             ((char >= 7'h61) && (char <= 7'h66)) )  // a-f
    begin
      to_val[4]   = 1'b0;
      to_val[3:0] = char[3:0] + 4'h9; // gives 10 - 15
    end
    else 
    begin
      to_val      = 5'b1_0000;
    end
  end
  endfunction

//***************************************************************************
// Code
//***************************************************************************
  // capture the rx_data_rdy for edge detection
  always @(posedge clk_rx)
  begin
    if (rst_clk_rx)
    begin
      old_rx_data_rdy <= 1'b0;
    end
    else
    begin
      old_rx_data_rdy <= rx_data_rdy;
    end
  end
  // Echo the incoming character to the output, if there is room in the FIFO
  always @(posedge clk_rx)
  begin
    if (rst_clk_rx)
    begin
      send_char_val <= 1'b0;
      send_char     <= 8'h00;
    end
    else if (new_char)
    begin
      send_char_val <= 1'b1;
      send_char     <= rx_data;
    end // if rst and new_char
    else
    begin
      send_char_val <= 1'b0;
    end
  end // always

  // For each character that is potentially part of an argument, we need to 
  // check that it is in the HEX range, and then figure out what the value is.
  // This is done using the function to_val
  wire [4:0]  char_to_digit = to_val(rx_data);
  wire        char_is_digit = !char_to_digit[4];

  // Assuming it is a value, the new digit is the least significant digit of
  // those that have already come in - thus we need to concatenate the new 4
  // bits to the right of the existing data
  wire [4*MAX_ARG_CH-1:0] arg_val       = {arg_sav,char_to_digit[3:0]};

  always @(posedge clk_rx)
  begin
    if (rst_clk_rx)
    begin
      state             <= IDLE;
      arg_sav           <= 28'b0;
      arg_cnt           <= 3'b0;
      send_resp_val     <= 1'b0;
      send_resp_type    <= RESP_ERR;
      send_resp_data    <= 16'h0000;
	  bt_data32         <= 32'h00000000;
    end
    else
    begin
      // Defaults - overridden in the appropriate state
      case (state)
        IDLE: begin // Wait for the '0'
          if (new_char && (rx_data[6:0] == 7'h30))
          begin
            state <= GET_ARG;
            arg_cnt <= 3'd6;
          end // if found 0
        end // state IDLE


        GET_ARG: begin
          // Get the correct number of characters of argument. Check that
          // all characters are legel HEX values.
          // Once the last character is successfully received, take action
          // based on what the current command is
          if (new_char)
          begin
            if (!char_is_digit)
            begin
              // Send an error response
              send_resp_val  <= 1'b1;
              send_resp_type <= RESP_ERR;
              state          <= SEND_RESP;
            end
            else // character IS a digit
            begin
              
              if (arg_cnt != 3'b000) // This is NOT the last char of arg
              begin
                // append the current digit to the saved ones
                arg_sav <= arg_val;
                // Wait for the next character
                arg_cnt <= arg_cnt - 1'b1;
              end // Not last char of arg
              else // This IS the last character of the argument - process
                  begin
                      bt_data32 <= arg_val[27:0];
					  // Send OK
                      send_resp_val     <= 1'b1;
                      send_resp_type    <= RESP_OK;
                      state             <= SEND_RESP;
              end // received last char of arg
            end // if the char is a valid HEX digit
          end // if new_char
        end // state GET_ARG

        SEND_RESP: begin
          // The response request has already been sent - all we need to
          // do is keep the request asserted until the response is complete.
          // Once it is complete, we return to IDLE
          if (send_resp_done)
          begin
            send_resp_val <= 1'b0;
            state         <= IDLE;
          end
        end // state SEND_RESP

        default: begin
          state <= IDLE;
        end // state default

      endcase
    end // if rst
  end // always
endmodule
