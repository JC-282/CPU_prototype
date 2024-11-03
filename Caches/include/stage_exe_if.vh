// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: interface
// description: interface for execution stage


`ifndef STAGE_EXE_IF_VH
`define STAGE_EXE_IF_VH
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;


interface stage_exe_if;

    word_t imemload_in, npc_in, rdat1_in, rdat2_in, imme_in;
    word_t rdat1_out, rdat2_out, npc_out, aluOut_out;
    word_t for_dat1_mem_in, for_dat1_wb_in, for_dat2_mem_in, for_dat2_wb_in;

    aluop_t aluOp_in;
    logic ALUsrc_in, jal_in;
    logic [1:0] regDst_in;
    logic [1:0] branch_in;
    logic memtoReg_in;
    logic [1:0] jump_in;
    logic regWrite_in;

    word_t jumpaddr_out, branchaddr_out;
    logic branchSel_out, jal_out, memtoReg_out, regWrite_out;
    logic [1:0] jump_out;
    logic [4:0] regSel_out;

    // three request units in exe
    logic halt_in, memRead_in, memWrite_in;
    logic halt_out, memRead_out, memWrite_out;


    modport ex
    (
        input imemload_in, npc_in, rdat1_in, rdat2_in, imme_in, aluOp_in,
        ALUsrc_in, regDst_in, branch_in, memtoReg_in, jump_in, regWrite_in, jal_in,
        halt_in,memRead_in,memWrite_in, for_dat1_mem_in, for_dat1_wb_in, for_dat2_mem_in, for_dat2_wb_in,

        output jumpaddr_out, branchaddr_out, branchSel_out, jump_out, jal_out, memtoReg_out,
        regWrite_out, regSel_out, rdat2_out,
        rdat1_out,npc_out,aluOut_out,
        halt_out, memRead_out, memWrite_out
    );









endinterface
`endif
