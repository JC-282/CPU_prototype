// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: vs source file
// description: This is the vs source file for the instruction fetch stage
`include "stage_if_if.vh"
`include "cpu_types_pkg.vh"
`include "haz_det_if.vh"
import cpu_types_pkg::*;

module stage_if
(
    input word_t init,
    input logic CLK, nRST,
    stage_if_if.sif stif,
    haz_det_if.s1 dhif
);


    assign stif.imemload_out = stif.imemload_in;
    program_counter pc (init, CLK, nRST, stif.ihit, stif.jump_in, stif.branchSel_in, stif.jumpaddr_in, stif.branchaddr_in, stif.rdata1_in, stif.imemaddr_out, stif.npc_out, dhif.stall);

endmodule
