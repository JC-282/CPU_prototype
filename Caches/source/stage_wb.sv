// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: source
// description: write back stage

`include "stage_wb_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module stage_wb
(
    input logic CLK, nRST,
    stage_wb_if.wb wbif
);
    assign wbif.npc_out      = wbif.npc_in;
    assign wbif.jal_out      = wbif.jal_in;
    assign wbif.regWrite_out = wbif.regWrite_in;
    assign wbif.regSel_out   = wbif.regSel_in;
    //write date select
    always_comb
    begin
       wbif.wdat_out = wbif.aluOut_in;

        if(wbif.memtoReg_in)
        begin
            wbif.wdat_out = wbif.dmemload_in;
        end
    end

endmodule

