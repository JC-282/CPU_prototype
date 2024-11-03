// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: interface
// description: forwarding unit interface
`ifndef FOR_UNIT_IF_VH
`define FOR_UNIT_IF_VH

`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

interface for_unit_if;
    logic [4:0] regSel_mem, regSel_wb;
    logic regWrite_mem, regWrite_wb;
    logic [4:0] rs_ex,rt_ex;
    logic [1:0] portaSel;
    logic [1:0] portbSel;

    modport fu
    (
        input regSel_mem, regSel_wb, regWrite_mem, regWrite_wb, rs_ex ,rt_ex,
        output portaSel, portbSel
    );

    modport ex
    (
        input portaSel, portbSel
    );

    modport tb
    (
        input portaSel, portbSel,
        output regSel_mem, regSel_wb, regWrite_mem, regWrite_wb, rs_ex ,rt_ex
    );
endinterface

`endif

