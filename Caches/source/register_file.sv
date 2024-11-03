// author: Jason Cai (Xinyuan Cai)
// email: cai282@purdue.edu
// description: The is the register file of the processor
`include "cpu_types_pkg.vh"
`include "register_file_if.vh"

import cpu_types_pkg::*;

module register_file
(
    input logic CLK, nRST,
    register_file_if.rf rfif
);

    word_t [31:0] register;
    word_t [31:0] nxt_register;


//read comb block
    assign rfif.rdat1 = register[rfif.rsel1];
    assign rfif.rdat2 = register[rfif.rsel2];

// register
    always_ff @ (negedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
           register <= '0;
        end
        else
        begin
            register <= nxt_register;
        end
    end

// write comb block
    always_comb
    begin
    nxt_register = register;
        if (rfif.WEN)
        begin
            if (rfif.wsel != 0)
            begin
                nxt_register[rfif.wsel] = rfif.wdat;
            end
        end
    end

endmodule
