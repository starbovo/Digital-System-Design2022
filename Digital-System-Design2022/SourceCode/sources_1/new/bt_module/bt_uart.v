`timescale 1ns/1ps


module bt_uart (
  input            clk_pin,      // Clock input (from pin)
  input            rst_pin,        // Active HIGH reset (from pin)

  // RS232 signals
  input            rxd_pin,        // RS232 RXD pin
  output           txd_pin,        // RS232 RXD pin

  //BT 
    output bt_pw_on,
    output bt_master_slave,
    output bt_sw_hw,
    output bt_rst_n,
    output bt_sw,
    
    output [31:0] bt_data32
  //seg7
    // output     [6:0] seg7_0_7bit,
    // output     [6:0] seg7_1_7bit,
    // output     [3:0] seg7_0_an,
    // output     [3:0] seg7_1_an,
    // output     seg7_0_dp,
    // output     seg7_1_dp
    );

//***************************************************************************
// Parameter definitions
//***************************************************************************

  parameter BAUD_RATE           = 9600;   

  parameter CLOCK_RATE_RX       = 100_000_000;
  parameter CLOCK_RATE_TX       = 100_000_000; 


  wire        rst_i,rst_1;          
  wire        rxd_i;         
  wire        txd_o;

  // From Clock Generator
  wire        clk_rx;         // Receive clock
  wire        clk_tx;         // Transmit clock
  wire        clk_samp;       // Sample clock
  wire        clock_locked;   // Locked signal from clk_core

  // From Reset Generator
  wire        rst_clk_rx;     // Reset, synchronized to clk_rx
  wire        rst_clk_tx;     // Reset, synchronized to clk_tx

  // From the RS232 receiver
  wire        rxd_clk_rx;     // RXD signal synchronized to clk_rx
  wire        rx_data_rdy;    // New character is ready
  wire [7:0]  rx_data;        // New character

  //wire [31:0] bt_data32;

  // From the response generator back to the command parser
  wire        send_resp_done;   // The response generation is complete

//***************************************************************************
// Code
//***************************************************************************

  // Instantiate input/output buffers
  IBUF IBUF_rst_i0      (.I (rst_1),      .O (rst_i));
  IBUF IBUF_rxd_i0      (.I (rxd_pin),      .O (rxd_i));
  OBUF OBUF_txd         (.I(txd_o),         .O(txd_pin));
  assign rst_1 = !rst_pin;

  // Instantiate the clock generator
  clk_gen clk_gen_i0 (
    .clk_pin         (clk_pin),         // Input clock pin - IBUFG is in core
    .rst_i           (rst_i),           // Asynchronous input from IBUF

    .rst_clk_tx      (rst_clk_tx),      // For clock divider

    .pre_clk_tx      ( ),      // Current divider

    .clk_rx          (clk_rx),          // Receive clock
    .clk_tx          (clk_tx),          // Transmit clock
    .clk_samp        ( ),        // Sample clock

    .en_clk_samp     ( ),     // Enable for clk_samp
    .clock_locked    (clock_locked)     // Locked signal from clk_core
  );

  // Instantiate the reset generator
  rst_gen rst_gen_i0 (
    .clk_rx          (clk_rx),          // Receive clock
    .clk_tx          (clk_tx),          // Transmit clock
    .clk_samp        ( ),        // Sample clock

    .rst_i           (rst_i),           // Asynchronous input - from IBUF
    .clock_locked    (clock_locked),    // Locked signal from clk_core

    .rst_clk_rx      (rst_clk_rx),      // Reset, synchronized to clk_rx
    .rst_clk_tx      (rst_clk_tx),      // Reset, synchronized to clk_tx
    .rst_clk_samp    ( )     // Reset, synchronized to clk_samp
  );

  // Instantiate the UART receiver
  uart_rx #(
    .BAUD_RATE   (BAUD_RATE),
    .CLOCK_RATE  (CLOCK_RATE_RX)
  ) uart_rx_i0 (
    .clk_rx      (clk_rx),              // Receive clock
    .rst_clk_rx  (rst_clk_rx),          // Reset, synchronized to clk_rx 

    .rxd_i       (rxd_i),               // RS232 receive pin
    .rxd_clk_rx  (rxd_clk_rx),          // RXD pin after sync to clk_rx
    
    .rx_data_rdy (rx_data_rdy),         // New character is ready
    .rx_data     (rx_data),             // New character
    .frm_err     ()                     // Framing error (unused)
  );

  // Instantiate the command parser
  cmd_parse cmd_parse_i0 (
    .clk_rx            (clk_rx),         // Clock input
    .rst_clk_rx        (rst_clk_rx),     // Reset - synchronous to clk_rx

    .rx_data           (rx_data),        // Character to be parsed
    .rx_data_rdy       (rx_data_rdy),    // Ready signal for rx_data

    // From Character FIFO
    .char_fifo_full    (), // The char_fifo is full

    // To/From Response generator
    .send_char_val     (),  // A character is ready to be sent
    .send_char         (),      // Character to be sent

    .send_resp_val     (),  // A response is requested
    .send_resp_type    (), // Type of response - see localparams
    .send_resp_data    (), // Data to be output

    .send_resp_done    (1), // The response generation is complete
	.bt_data32                (bt_data32)
  );

  
  // seg7decimal seg7_0(
  //   .x          (bt_data32[31:16]),
  //   .clk        (clk_tx),
  //   .clr        (rst_clk_tx),
  //   .a_to_g     (seg7_0_7bit),
  //   .an         (seg7_0_an),
  //   .dp         (seg7_0_dp)
  //   );

  // seg7decimal seg7_1(
  //   .x          (bt_data32[15:0]),
  //   .clk        (clk_tx),
  //   .clr        (rst_clk_tx),
  //   .a_to_g     (seg7_1_7bit),
  //   .an         (seg7_1_an),
  //   .dp         (seg7_1_dp)
  //   );


assign bt_master_slave = 1;
assign bt_sw_hw        = 0;
assign bt_rst_n        = 1;
assign bt_sw           = 1;
assign bt_pw_on        = 1;

endmodule