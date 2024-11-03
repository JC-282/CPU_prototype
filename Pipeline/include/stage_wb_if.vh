// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: interface
// description: write back stage interface
`ifndef STAGE_WB_IF_VH
`define STAGE_WB_IF_VH
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

interface stage_wb_if;
    logic memtoReg_in;
    logic jal_in, jal_out, regWrite_in, regWrite_out;
    logic [4:0] regSel_in,regSel_out;
    word_t dmemload_in;
    word_t aluOut_in;
    word_t wdat_out;
    word_t npc_in, npc_out;

    modport wb
    (
        input  jal_in, regWrite_in, regSel_in, memtoReg_in, dmemload_in, aluOut_in, npc_in,
        output jal_out, regWrite_out, regSel_out, wdat_out, npc_out
    );

endinterface
`endif

