// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: interface file
// description: this is the interface file for control unit

`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH
`include "cpu_types_pkg.vh"

interface control_unit_if;

import cpu_types_pkg::*;
    // signal
    logic jal;
    logic [1:0] branch, jump;
    logic memRead, memtoReg, memWrite;
    logic aluSrc; // 0 from register, 1 from imme
    logic [1:0] regDst;
    logic regWrite;
    logic [1:0] extender;
    logic halt;
    logic datomic;
    // op code
    opcode_t op;
    aluop_t aluOp;
    funct_t funcop;
    // port for control unit
    modport cu
    (
        input   op, funcop,

        output  jump, jal, branch,
                memRead, memWrite,
                memtoReg,
                aluSrc,
                regDst, regWrite,
                aluOp,
                extender, halt,
                datomic
    );
    // port for program counter
    modport pc
    (
        input jump, branch
    );

/*
    // port for request unit
    modport ru
    (
        input memRead, memWrite
    );

    // port for cache
    modport ca
    (
        output  op, funcop,

        input   memRead, memWrite

    );

    // port for register file
    modport rf
    (
        input regDst, regWrite
    );

    // port for data path
    modport dp
    (
        input   jump, jal, branch,
                memtoReg,
                aluSrc,
                extender, halt
    );

    // port for alu
    modport al
    (
        input   aluOp
    );
*/
    // testbench
    modport tb
    (
        input   jump, jal, branch,
                memRead, memWrite,
                memtoReg,
                aluSrc,
                regDst, regWrite,
                aluOp,
                extender,halt,

        output   op, funcop
    );
endinterface
`endif // CONTROL_UNIT_IF

