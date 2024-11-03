// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type:
// description:

`include "haz_det_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module haz_det(
    input logic CLK, nRST,
    haz_det_if.hd hdif
);
    logic taken;
    assign taken = 0;
    always_comb
    begin
        hdif.stall = 0;
        hdif.flush_if = 0;
        hdif.flush_id = 0;
        hdif.flush_ex = 0;
        //output logic for jump
        if (hdif.jump)
        begin
            hdif.flush_if = 1;
            hdif.flush_id = 1;
            hdif.flush_ex = 1;
        end
        //output logic for branch
        else if(!taken && hdif.branchSel)
        begin
            hdif.flush_if = 1;
            hdif.flush_id = 1;
            hdif.flush_ex = 1;
        end
        //Raw hazard
        else if(hdif.memRead_ex && ((hdif.rt_ex == hdif.imemload_id[25:21]) || hdif.rt_ex == hdif.imemload_id[20:16]))
        begin
            hdif.stall = 1;
            hdif.flush_id = 1;
        end
    end



endmodule


