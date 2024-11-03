// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: interface file
// description: this is the interface file for request unit

`ifndef REQUEST_UNIT_IF_VH
`define REQUEST_UNIT_IF_VH
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;


interface request_unit_if;

    logic ihit, dhit, memRead, memWrite;
    logic dmemWen, dmemRen, imemRen;
    logic halt;

    modport ru
    (
        input ihit, dhit, memRead, memWrite, halt,
        output dmemWen, dmemRen, imemRen
    );


    modport tb
    (
        input dmemWen, dmemRen, imemRen,
        output ihit, dhit, memRead, memWrite, halt
    );
endinterface

`endif

