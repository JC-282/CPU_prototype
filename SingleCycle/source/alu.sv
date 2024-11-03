/*
author: Xinyuan Cai
email: cai282@purdue.edu
file type: code sv file
description: The is the fundemental code file for function for ALU
*/
`include "cpu_types_pkg.vh"
`include "alu_if.vh"

import cpu_types_pkg::*;

module alu
(
    input logic CLK,
    alu_if.alu aluif
);
    // negative flag setting
    assign aluif.negative = aluif.outport[31];

    // zero flag setting
    assign aluif.zero = aluif.outport == 0 ? 1 : 0;

    // arithmetic comb block
    always_comb
    begin
        aluif.overflow = 0;
        aluif.outport = 0;
        case (aluif.aluop)
            ALU_SLL: begin
                aluif.outport = aluif.portb << aluif.porta[4:0];
            end
            ALU_SRL: begin
                aluif.outport = aluif.portb >> aluif.porta[4:0];
            end
            ALU_ADD: begin
                aluif.outport = signed'(aluif.porta) + signed'(aluif.portb);
                aluif.overflow = (aluif.porta[31] == aluif.portb[31]
                                && aluif.porta[31] != aluif.outport[31]);
            end
            ALU_SUB: begin
                aluif.outport = signed'(aluif.porta) - signed'(aluif.portb);
                aluif.overflow = (aluif.porta[31] != aluif.portb[31]
                                && aluif.porta[31] != aluif.outport[31]);
            end
            ALU_AND: begin
                aluif.outport = aluif.porta & aluif.portb;
            end
            ALU_OR: begin
                aluif.outport = aluif.porta | aluif.portb;
            end
            ALU_XOR: begin
                aluif.outport = aluif.porta ^ aluif.portb;
            end
            ALU_NOR: begin
                aluif.outport = ~(aluif.porta | aluif.portb);
            end
            ALU_SLT: begin
                aluif.outport = signed'(aluif.porta) < signed'(aluif.portb);
            end
            ALU_SLTU: begin
                aluif.outport = unsigned'(aluif.porta) < unsigned'(aluif.portb);
            end
        endcase
    end

endmodule
