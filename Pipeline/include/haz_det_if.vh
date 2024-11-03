// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: interface
// description: hazard detect unit interface
`ifndef HAZ_DET_IF_VH
`define HAZ_DET_IF_VH

`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
interface haz_det_if;
    logic stall;
    logic flush_if,flush_id,flush_ex;
    logic branchSel;
    logic [1:0] jump;
    logic memRead_ex;
    logic [4:0] rt_ex;
    word_t imemload_id;

    modport hd (
        input branchSel,jump,memRead_ex,rt_ex,imemload_id,
        output stall,flush_if,flush_id,flush_ex
    );

    modport tb (
        input stall,flush_if,flush_id,flush_ex,
        output branchSel,jump,memRead_ex,rt_ex,imemload_id
    );

    modport s1
    (
        input stall
    );


endinterface
`endif

