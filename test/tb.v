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
    reg iEn;
    reg iData_in;
    reg iClk;
    reg iRst;
    reg iLoad_key;
    reg iLoad_msg;
    wire oClk_slow;
    wire oData_out;
    wire oDone_flag;

    // Instantiate the top module
    tt_um_franco_xor_top user_project (

      `ifdef GL_TEST
         .VPWR(1'b1),
         .VGND(1'b0),
       `endif

        .iEn(iEn),
        .iData_in(iData_in),
        .iClk(iClk),
        .iRst(iRst),
        .iLoad_key(iLoad_key),
        .iLoad_msg(iLoad_msg),
        .oClk_slow(oClk_slow),
        .oData_out(oData_out),
        .oDone_flag(oDone_flag)
    );
endmodule