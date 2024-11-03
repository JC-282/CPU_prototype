// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: testbench
// description: forwarding unit test bench
`include "for_unit_if.vh"
`include "cpu_types_pkg.vh"
`timescale 1 ns / 1 ns
import cpu_types_pkg::*;

module for_unit_tb;
    parameter PERIOD = 10;

    //CLK
    logic CLK = 0, nRST;
    always #(PERIOD/2) CLK++;

    //interface
    for_unit_if fuif();

    test PROG (CLK, nRST,fuif);

    //DUT
    `ifndef MAPPED
        for_unit DUT (CLK, nRST,fuif);
    `else
        for_unit DUT
        (
            .\CLK(CLK),
            .\nRST(nRST),
            .\fuif.regSel_mem (fuif.regSel_mem),
            .\fuif.regSel_wb (fuif.regSel_wb),
            .\fuif.regWrite_mem (fuif.regWrite_mem),
            .\fuif.regWrite_wb (fuif.regWrite_wb),
            .\fuif.portaSel (fuif.portaSel),
            .\fuif.portbSel (fuif.portbSel),
            .\fuif.rt_ex (fuif.rt_ex),
            .\fuif.rs_ex (fuif.rs_ex),
        );
    `endif

endmodule

program test
(
    input logic CLK,
    output logic nRST,
    for_unit_if.tb fuif
);

task check;
        input string tag;
        input logic [1:0] ex_portaSel;
        input logic [1:0] ex_portbSel;

    begin
        @(posedge CLK);
        if (fuif.portaSel != ex_portaSel)
            $display("For %s case, portaSel is incorrect\n %d",tag,fuif.portaSel);

        if (fuif.portbSel != ex_portbSel)
            $display("For %s case, portbSel is incorrect\n %d",tag,fuif.portbSel);
    end
endtask
    initial
    begin
        //initialize
        fuif.regSel_mem = 0;
        fuif.regSel_wb = 0;
        fuif.regWrite_mem = 0;
        fuif.regWrite_wb =0;
        fuif.rs_ex = 0;
        fuif.rt_ex = 0;

        //no forwarding
        fuif.regSel_mem = 5'd5;
        fuif.regSel_wb = 5'd7;
        fuif.regWrite_mem = 1;
        fuif.regWrite_wb = 1;
        fuif.rs_ex = 5'd10;
        fuif.rt_ex = 5'd11;
        check("NO forwarding",0,0);

        //with forwarding
        fuif.regSel_mem = 5'd5;
        fuif.regSel_wb = 5'd11;
        fuif.regWrite_mem = 1;
        fuif.regWrite_wb = 1;
        fuif.rs_ex = 5'd5;
        fuif.rt_ex = 5'd11;
        check("rs_mem/rt_wb",1,2);

        fuif.regSel_mem = 5'd5;
        fuif.regSel_wb = 5'd10;
        fuif.regWrite_mem = 1;
        fuif.regWrite_wb = 1;
        fuif.rs_ex = 5'd10;
        fuif.rt_ex = 5'd5;
        check("rs_wb/rt_mem",2,1);

        fuif.regSel_mem = 5'd10;
        fuif.regSel_wb = 5'd10;
        fuif.regWrite_mem = 1;
        fuif.regWrite_wb = 1;
        fuif.rs_ex = 5'd10;
        fuif.rt_ex = 5'd11;
        check("rs_wb_mem",1,0);

        fuif.regSel_mem = 5'd11;
        fuif.regSel_wb = 5'd11;
        fuif.regWrite_mem = 1;
        fuif.regWrite_wb = 1;
        fuif.rs_ex = 5'd10;
        fuif.rt_ex = 5'd11;
        check("rt_wb_mem",0,1);

        fuif.regSel_mem = 5'd5;
        fuif.regSel_wb = 5'd7;
        fuif.regWrite_mem = 1;
        fuif.regWrite_wb = 1;
        fuif.rs_ex = 5'd5;
        fuif.rt_ex = 5'd5;
        check("rt_rs_mem",1,1);

        fuif.regSel_mem = 5'd5;
        fuif.regSel_wb = 5'd7;
        fuif.regWrite_mem = 1;
        fuif.regWrite_wb = 1;
        fuif.rs_ex = 5'd7;
        fuif.rt_ex = 5'd7;
        check("rt_rs_wb",2,2);
        $finish;
    end
endprogram


