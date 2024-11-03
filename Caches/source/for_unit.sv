// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: source
// description: forward unit

`include "for_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module for_unit
(
    input logic CLK,
    input logic nRST,
    for_unit_if.fu fuif
);

    always_comb
    begin
        fuif.portaSel = 0;
        fuif.portbSel = 0;

        if ((fuif.rs_ex == fuif.regSel_mem) && fuif.regWrite_mem)
        begin
            fuif.portaSel = 1;
        end
        else if ((fuif.rs_ex == fuif.regSel_wb) && fuif.regWrite_wb)
        begin
            fuif.portaSel = 2;
        end

        if ((fuif.rt_ex == fuif.regSel_mem) && fuif.regWrite_mem)
        begin
            fuif.portbSel = 1;
        end
        else if ((fuif.rt_ex == fuif.regSel_wb) && fuif.regWrite_wb)
        begin
            fuif.portbSel = 2;
        end
    end
endmodule

