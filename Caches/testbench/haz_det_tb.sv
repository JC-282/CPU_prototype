// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: test bench
// description: hazard detect unit test bench

`include "haz_det_if.vh"
`include "cpu_types_pkg.vh"
`timescale 1 ns / 1 ns
import cpu_types_pkg::*;

module haz_det_tb;

    parameter PERIOD = 10;

    //clk
    logic CLK = 0, nRST;
    always #(PERIOD/2) CLK ++;

    //interface
    haz_det_if hdif();

    test PROG (CLK,nRST,hdif);

    //DUT

    `ifndef MAPPED
        haz_det DUT (CLK,nRST,hdif);
    `else
        haz_det DUT
        (
            .\CLK (CLK),
            .\nRST (nRST),
            .\hdif.stall (hdif.stall),
            .\hdif.flush_if (hdif.flush_if),
            .\hdif.fulsh_id (hdif.flush_id),
            .\hdif.flush_ex (hdif.flush_ex),
            .\hdif.branchSel (hdif.branchSel),
            .\hdif.jump (hdif.jump),
            .\hdif.memRead_ex (hdif.memRead_ex),
            .\hdif.rt_ex (hdif.rt_ex),
            .\hdif.imemload_id (hdif.imemload_id)
        );
    `endif
endmodule

program test
(
    input logic CLK,
    output logic nRST,
    haz_det_if.tb hdtb
);
    parameter PERIOD = 10;

    // RESET task
    task RESET;
        begin
            nRST = 0;
            @(posedge CLK);
            @(posedge CLK);
            @(negedge CLK);

            nRST = 1;
            @(posedge CLK);
            @(posedge CLK);
        end
    endtask

task check;
        input string tag;
        input logic ex_stall;
        input logic ex_flush_if;
        input logic ex_flush_id;
        input logic ex_flush_ex;
    begin
        @(posedge CLK);
        if(hdif.stall != ex_stall)
            $display("For %s case, stall is incorrect",tag);

        if(hdif.flush_if != ex_flush_if)
            $display("For %s case, flush_if is incorrect",tag);

        if(hdif.flush_id != ex_flush_id)
            $display("For %s case, flush_id is incorrect",tag);

        if(hdif.flush_ex != ex_flush_ex)
            $display("For %s case, flush_ex is incorrect",tag);
    end
endtask

    initial
    begin
        //initialize
        hdif.branchSel = 0;
        hdif.jump = 0;
        hdif.memRead_ex = 0;
        hdif.rt_ex = 5'd6;
        hdif.imemload_id = '0;

        RESET();
        //no hazard
        hdif.branchSel = 0;
        hdif.jump = 0;
        hdif.memRead_ex = 0;
        hdif.rt_ex = 5'd6;
        hdif.imemload_id[25:21] = 5'd3;
        hdif.imemload_id[20:16] = 5'd5;
        check("No",0,0,0,0);

        hdif.branchSel = 0;
        hdif.jump = 0;
        hdif.memRead_ex = 1;
        hdif.rt_ex = 5'd6;
        hdif.imemload_id[25:21] = 5'd3;
        hdif.imemload_id[20:16] = 5'd5;
        check("No_memRead",0,0,0,0);

        hdif.branchSel = 0;
        hdif.jump = 0;
        hdif.memRead_ex = 0;
        hdif.rt_ex = 5'd6;
        hdif.imemload_id[25:21] = 5'd6;
        hdif.imemload_id[20:16] = 5'd6;
        check("No_reg",0,0,0,0);

        //branch hazard
        hdif.branchSel = 1;
        hdif.jump = 0;
        hdif.memRead_ex = 0;
        hdif.rt_ex = 5'd6;
        hdif.imemload_id[25:21] = 5'd6;
        hdif.imemload_id[20:16] = 5'd6;
        check("branch",0,1,1,1);

        //jump hazard
        hdif.branchSel = 0;
        hdif.jump = 1;
        hdif.memRead_ex = 1;
        hdif.rt_ex = 5'd6;
        hdif.imemload_id[25:21] = 5'd6;
        hdif.imemload_id[20:16] = 5'd6;
        check("j/jal",0,1,1,1);

        hdif.branchSel = 1;
        hdif.jump = 2;
        hdif.memRead_ex = 0;
        hdif.rt_ex = 5'd6;
        hdif.imemload_id[25:21] = 5'd6;
        hdif.imemload_id[20:16] = 5'd6;
        check("jr",0,1,1,1);

        //Ram hazard
        hdif.branchSel = 0;
        hdif.jump = 0;
        hdif.memRead_ex = 1;
        hdif.rt_ex = 5'd6;
        hdif.imemload_id[25:21] = 5'd6;
        hdif.imemload_id[20:16] = 5'd5;
        check("raw_reg1",1,0,1,0);

        hdif.branchSel = 0;
        hdif.jump = 0;
        hdif.memRead_ex = 1;
        hdif.rt_ex = 5'd6;
        hdif.imemload_id[25:21] = 5'd7;
        hdif.imemload_id[20:16] = 5'd6;
        check("raw_reg2",1,0,1,0);
        $finish;
    end

endprogram



