// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: interface
// description: This is the interface for stage one (instruction fetch)



`ifndef STAGE_IF_IF_VH
`define STAGE_IF_IF_VH

`include "cpu_types_pkg.vh"

interface stage_if_if;
    // import types
    import cpu_types_pkg::*;

    logic [1:0] jump_in;
    logic branchSel_in, ihit;
    word_t jumpaddr_in, branchaddr_in, rdata1_in;
    word_t npc_out;
    word_t imemaddr_out;
    word_t imemload_in, imemload_out;

    modport sif
    (
        input jump_in, branchSel_in, jumpaddr_in, branchaddr_in, rdata1_in, ihit, imemload_in,
        output npc_out, imemaddr_out, imemload_out
    );



endinterface
`endif
