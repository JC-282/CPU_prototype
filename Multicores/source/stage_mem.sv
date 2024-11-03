// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: source
// description: memory stage

//`include "request_unit_if.vh"
`include "stage_mem_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module stage_mem
(
    input logic CLK, nRST,
    stage_mem_if.mem memif
);
    //interface
   // request_unit_if ruif();

    //function call
    //request_unit(CLK,nRST,ruif);


    assign memif.memtoReg_out = memif.memtoReg_in;
    assign memif.jal_out      = memif.jal_in;
    assign memif.regWrite_out = memif.regWrite_in;
    assign memif.regSel_out   = memif.regSel_in;

    assign memif.jump_out       = memif.jump_in;
    assign memif.branchSel_out  = memif.branchSel_in;
    assign memif.branchaddr_out = memif.branchaddr_in;
    assign memif.jumpaddr_out   = memif.jumpaddr_in;
    assign memif.npc_out        = memif.npc_in;
    assign memif.rdat1_out      = memif.rdat1_in;
    assign memif.aluOut_out     = memif.aluOut_in;
    assign memif.dmemaddr_out   = memif.aluOut_in;
    assign memif.dmemstore_out  = memif.dmemstore_in;
    assign memif.dmemload_out   = memif.dmemload_in;
    assign memif.halt_out       = memif.halt_in;
    assign memif.memRead_out    = memif.memRead_in;
    assign memif.memWrite_out   = memif.memWrite_in;
    assign memif.datomic_out    = memif.datomic_in;
    /*//request unit
    assign ruif.ihit        = memif.ihit;
    assign ruif.dhit        = memif.dhit;
    assign ruif.memRead     = memif.memRead;
    assign ruif.memWrite    = memif.memWrite;
    assign ruif.halt        = memif.halt;
    */
endmodule

