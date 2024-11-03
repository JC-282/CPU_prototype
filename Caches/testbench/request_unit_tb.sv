// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: testbench
// description: This is the testbench to test request unit

`include "control_unit_if.vh"


`include "cpu_types_pkg.vh"

`timescale 1 ns / 1 ns

import cpu_types_pkg::*;
module request_unit_tb;

    parameter PERIOD = 10;
    parameter CPUS = 1;

    logic CLK = 0, nRST;

    always #(PERIOD/2) CLK++;


    //interface
    request_unit_if ruif();
    test PROG (CLK, nRST, ruif);

`ifndef MAPPED
    request_unit DUT (CLK, nRST, ruif);
`else
    request_unit DUT
    (
        .\CLK (CLK),
        .\nRST (nRST),
        .\ruif.ihit (ruif.ihit),
        .\ruif.dhit (ruif.dhit),
        .\ruif.memRead (ruif.memRead),
        .\ruif.memWrite (ruif.memWrite),
        .\ruif.dmemWen (ruif.dmemWen),
        .\ruif.dmemRen (ruif.dmemRen),
        .\ruif.imemRen (ruif.imemRen),
        .\ruif.halt (ruif.halt)
    );
`endif
endmodule


program test
(
    input logic CLK,
    output logic nRST,
    request_unit_if.tb ruif
);
task reset;
    nRST = 0;
    @(posedge CLK);
    @(posedge CLK);
    nRST = 1;
    @(posedge CLK);
    @(posedge CLK);
endtask

task check;
        input logic dmemWen,dmemRen,imemRen;
    begin
        @(posedge CLK);
        if (ruif.dmemWen != dmemWen)
        begin
            $display("dmemWen, incorrect, %d", ruif.dmemWen);
        end
        if (ruif.dmemRen != dmemRen)
        begin
            $display("dmemWen, incorrect, %d", ruif.dmemRen);
        end
        if (ruif.imemRen != imemRen)
        begin
            $display("imemWen, incorrect, %d", ruif.imemRen);
        end
        $finish;
    end
endtask


    initial
    begin
        reset();
        ruif.dhit = 0;
        ruif.ihit = 1;
        ruif.halt = 0;
        ruif.memRead = 0;
        ruif.memWrite = 1;
        check(1,0,1);

        reset();
        ruif.dhit = 0;
        ruif.ihit = 1;
        ruif.halt = 0;
        ruif.memRead = 1;
        ruif.memWrite = 0;
        check(0,1,1);

        reset();
        ruif.dhit = 0;
        ruif.ihit = 0;
        ruif.halt = 1;
        ruif.memRead = 0;
        ruif.memWrite = 0;
        check(0,0,0);
        $finish;

    end
endprogram

