// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: interface
// description: mem stage interface

`ifndef STAGE_MEM_IF_VH
`define STAGE_MEM_IF_VH
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

interface stage_mem_if;
    logic [1:0] jump_in, jump_out;
    logic branchSel_in, branchSel_out;
    logic halt_in,memRead_in,memWrite_in;
    logic halt_out,memRead_out,memWrite_out;
    word_t branchaddr_in, branchaddr_out;
    word_t jumpaddr_in, jumpaddr_out;
    word_t npc_in, npc_out;
    word_t rdat1_in, rdat1_out;
    word_t aluOut_in, aluOut_out;
    word_t dmemaddr_out;
    word_t dmemstore_in, dmemstore_out;
    word_t dmemload_in, dmemload_out;
    logic datomic_in, datomic_out;

    ///////////////WB//////////////////
    logic memtoReg_in,memtoReg_out;
    logic jal_in, jal_out;
    logic regWrite_in,regWrite_out;
    logic [4:0] regSel_in;
    logic [4:0] regSel_out;
    ///////////////////////////////////

    modport mem
    (
        input   jump_in,branchSel_in,
                branchaddr_in, jumpaddr_in,npc_in,
                rdat1_in,aluOut_in,
                dmemstore_in,dmemload_in,
                memtoReg_in, jal_in,regWrite_in,regSel_in,
                halt_in,memRead_in,memWrite_in,datomic_in,
        output  jump_out,branchSel_out,
                branchaddr_out,jumpaddr_out,npc_out,
                rdat1_out,aluOut_out,
                dmemaddr_out,
                dmemstore_out,dmemload_out,
                memtoReg_out,jal_out,regWrite_out,regSel_out,
                halt_out,memRead_out,memWrite_out,datomic_out
    );


endinterface
`endif

