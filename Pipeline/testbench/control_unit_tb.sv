// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: testbench
// description: This is the testbench to test control unit

`include "control_unit_if.vh"


`include "cpu_types_pkg.vh"

`timescale 1 ns / 1 ns

import cpu_types_pkg::*;
module control_unit_tb;

    parameter PERIOD = 10;

    logic CLK = 0;

    always #(PERIOD/2) CLK++;

    control_unit_if cuif();
    test PROG(CLK, cuif);

`ifndef MAPPED
    control_unit DUT(cuif);
`else
    control_unit DUT(
        .\cuif.op (cuif.op),
        .\cuif.aluOp (cuif.aluOp),
        .\cuif.funcop (cuif.funcop),
        .\cuif.jal (cuif.jal),
        .\cuif.branch (cuif.branch),
        .\cuif.jump (cuif.jump),
        .\cuif.memRead (cuif.memRead),
        .\cuif.memtoReg (cuif.memtoReg),
        .\cuif.memWrite (cuif.memWrite),
        .\cuif.aluSrc (cuif.aluSrc),
        .\cuif.regDst (cuif.regDst),
        .\cuif.regWrite (cuif.regWrite),
        .\cuif.extender (cuif.extender),
        .\cuif.halt (cuif.halt)
    );
`endif
endmodule


program test
(
    input logic CLK,
    control_unit_if.tb cuif
);
    import cpu_types_pkg::*;
task check;
    input logic jal,aluSrc,memRead,memWrite,memtoReg,regWrite,halt;
    input logic [1:0] jump,regDst,extender,branch;
    input aluop_t aluOp;
    begin
        @(posedge CLK);

        if (cuif.jump != jump)
        begin
            $display("jump,incorrect %d",cuif.jump);
        end
        if (cuif.jal != jal)
        begin
            $display("jal,incorrect%d",cuif.jal);
        end
        if (cuif.branch != branch)
        begin
            $display("branch,incorrect%d",cuif.branch);
        end
        if (cuif.memRead != memRead)
        begin
            $display("memRead,incorrect%d",cuif.memRead);
        end
        if (cuif.memWrite != memWrite)
        begin
            $display("memWrite,incorrect%d",cuif.memWrite);
        end
        if (cuif.memtoReg != memtoReg)
        begin
            $display("memtoReg,incorrect%d",cuif.memtoReg);
        end
        if (cuif.aluSrc != aluSrc)
        begin
            $display("aluSrc,incorrect%d",cuif.aluSrc);
        end
        if (cuif.regDst != regDst)
        begin
            $display("regDst,incorrect%d",cuif.regDst);
        end
        if (cuif.regWrite != regWrite)
        begin
            $display("reWrite,incorrect%d",cuif.regWrite);
        end
        if (cuif.aluOp != aluop_t'(aluOp))
        begin
            $display("aluOp,incorrect%d",cuif.aluOp);
        end
        if (cuif.extender != extender)
        begin
            $display("extender,incorrect%d",cuif.extender);
        end
        if(cuif.halt != halt)
        begin
            $display("halt,incorect%d",cuif.halt);
        end
    end
endtask


    initial
    begin
        cuif.op = opcode_t'('0);
        cuif.funcop = funct_t'(0);

        cuif.op = opcode_t'('0);
        cuif.funcop = funct_t'(6'b100000);
        check(0,0,0,0,0,1,0,'0,0,1,0,ALU_ADD);

        cuif.op = opcode_t'(6'b000011);
        cuif.funcop = funct_t'(6'b000000);
        check(1,1,0,0,0,1,0,1,2,1,0,ALU_SLL);

        cuif.op = opcode_t'(6'b100011);
        cuif.funcop = funct_t'(6'b000000);
        check(0,1,1,0,1,1,0,0,1,1,0,ALU_ADD);

        cuif.op = opcode_t'(6'b000101);
        cuif.funcop = funct_t'(6'b000000);
        check(0,0,0,0,0,0,0,0,1,1,2,ALU_SUB);
        $finish;
    end

endprogram



