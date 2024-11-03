// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: sv source file
// description: this is the sv source file for request unit

`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

import cpu_types_pkg::*;

module request_unit
(
    input logic CLK, nRST,
    request_unit_if.ru ruif
);


    //logic n_halt; // next halt logic for doing latch for halt signal
    logic n_imemRen, n_dmemWen, n_dmemRen;

    //assign n_halt = (ruif.op == HALT) ? 1 : 0;
    assign n_imemRen = (ruif.halt) ? 0 : 1;
    //assign n_dmemWen = (ruif.memWrite == 1 && ruif.dhit == 0 && ruif.ihit) ? 1 : 0;
    //assign n_dmemWen = (ruif.memWrite == 1 && ruif.dhit == 0) ? 1 : 0;
    //assign n_dmemRen = (ruif.memRead == 1 && ruif.dhit == 0 && ruif.ihit) ? 1 : 0;
    //assign n_dmemRen = (ruif.memRead == 1 && ruif.dhit == 0) ? 1 : 0;

    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            //ruif.halt <= 0;
            ruif.imemRen <= 1;
            ruif.dmemWen <= 0;
            ruif.dmemRen <= 0;
        end
        else
        begin
            //ruif.halt <= (ruif.halt | n_halt);
            ruif.imemRen <= n_imemRen;
            ruif.dmemWen <= n_dmemWen;
            ruif.dmemRen <= n_dmemRen;
        end
    end

    always_comb
    begin
        n_dmemWen = ruif.dmemWen;
        n_dmemRen = ruif.dmemRen;
        if (ruif.memWrite == 1 && ruif.dhit == 0 && ruif.ihit)
        begin
            n_dmemWen = 1;
        end
        else if (ruif.dmemWen == 1 && (!(ruif.memWrite == 1 && ruif.dhit == 0)))
        begin
            n_dmemWen = 0;
        end

        if (ruif.memRead == 1 && ruif.dhit == 0 && ruif.ihit)
        begin
            n_dmemRen = 1;
        end
        else if (ruif.dmemRen == 1 && (!(ruif.memRead == 1 && ruif.dhit == 0)))
        begin
            n_dmemRen = 0;
        end
    end


endmodule

