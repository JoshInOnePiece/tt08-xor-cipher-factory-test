`default_nettype none
`timescale 1ns / 1ps

module tb();

    
     // Dump the signals to a VCD file. You can view it with gtkwave.
    initial begin
      $dumpfile("tb.vcd");
      $dumpvars(0, tb);
      #1;
    end

    // Testbench signals
    reg iSerial_in;
    reg iClk;
    reg iRst;
    reg iEn;
    reg iLoad_key;
    reg iLoad_msg;
    wire oSerial_out;
    wire oSerial_start;
    wire oSerial_end;

    // Instantiate the top module
    tt_um_franco_xor_top user_project (

      `ifdef GL_TEST
         .VPWR(1'b1),
         .VGND(1'b0),
       `endif

      .iSerial_in(iSerial_in),
      .iClk(iClk),
      .iRst(iRst),
      .iEn(iEn),
      .iLoad_key(iLoad_key),
      .iLoad_msg(iLoad_msg),
      .oSerial_out(oSerial_out),
      .oSerial_start(oSerial_start),
      .oSerial_end(oSerial_end)
    );
endmodule