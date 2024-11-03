/*
author: Xinyuan Cai
email: cai282@purdue.edu
file type: interface
description: this is the interface for Arithmetic Logic Unit (ALU)
*/

`ifndef ALU_IF_VH
`define ALU_IF_VH

`include "cpu_types_pkg.vh"

interface alu_if;
    // import types
    import cpu_types_pkg::*;

    logic   negative, overflow, zero;
    aluop_t aluop;
    word_t  porta, portb, outport;

    modport alu
    (
        input aluop, porta, portb,
        output negative, outport, overflow, zero
    );

    modport tb
    (
        input negative, outport, overflow, zero,
        output aluop, porta, portb
    );


endinterface
`endif

