// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: interface
// description: instruction decode stage

`ifndef STAGE_ID_IF_VH
`define STAGE_ID_IF_VH
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
interface stage_id_if;

    word_t npc_in, npc_out;
    word_t imemload_in, imemload_out;

    //control unit///////////////////
    logic halt_out;
    logic regWrite_out;
    logic memWrite_out, memRead_out, memtoReg_out;
    logic alusrc_out;
    logic jal_out;
    logic [1:0] jump_out;
    logic [1:0] regDst_out,branch_out;
    aluop_t aluOp_out;
    //logic [1:0] extender;
    //////////////////////////////////

    //reg file////////////////////////
    word_t rdat1_out, rdat2_out;
    word_t wdatWB_in, npcWB_in;
    logic regWriteWB_in,jalWB_in;
    logic [4:0] regSelWB_in;
    //////////////////////////////////

    //extend//////////////////////////
    word_t imme_out;
    //////////////////////////////////

    modport id
    (
        input   npc_in,imemload_in,wdatWB_in,
                npcWB_in,regWriteWB_in,jalWB_in,regSelWB_in,

        output  npc_out, imemload_out,
                halt_out,regWrite_out,
                memWrite_out,memRead_out,memtoReg_out,
                alusrc_out,regDst_out,branch_out,
                jal_out, jump_out,
                aluOp_out,
                rdat1_out,rdat2_out,
                imme_out
    );
endinterface

`endif

