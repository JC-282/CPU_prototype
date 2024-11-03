/*
author: Xinyuan Cai
email: cai282@purdue.edu
file type: fpga wrapper
description: This the fpga wrapper file for alu
*/

`include "alu_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module alu_fpga
(
    input logic CLOCK_50,
    input logic [3:0] KEY,
    input logic [17:0] SW,
    output logic [3:0] LEDG,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7
);

    // interface
    alu_if aluif();

    // call sv function
    alu al (CLOCK_50, aluif);

    // implement the segment LED decoder
    seg_decode sd1 (aluif.outport[3:0],   HEX0);
    seg_decode sd2 (aluif.outport[7:4],   HEX1);
    seg_decode sd3 (aluif.outport[11:8],  HEX2);
    seg_decode sd4 (aluif.outport[15:12], HEX3);
    seg_decode sd5 (aluif.outport[19:16], HEX4);
    seg_decode sd6 (aluif.outport[23:20], HEX5);
    seg_decode sd7 (aluif.outport[27:24], HEX6);
    seg_decode sd8 (aluif.outport[31:28], HEX7);

    word_t rb, nextrb;

    assign nextrb = (SW[17]) ? word_t'({{15{SW[16]}}, SW[16:0]}) : (rb);
    assign aluif.porta = word_t'({{15{SW[16]}}, SW[16:0]});
    assign aluif.portb = rb;
    assign aluif.aluop = aluop_t'(~KEY[3:0]);
    assign LEDG[3:0] = aluif.aluop;


    always_ff @ (posedge CLOCK_50)
    begin
        rb <= nextrb;
    end



endmodule


// The following module is to decode the 7 segments LED display
module seg_decode
(
    input logic [3:0] value,
    output logic [6:0] lit
);
    always_comb
    begin
        lit = 0;
        casez (value)
            0: lit =  7'b1000000;
            1: lit =  7'b1111001;
            2: lit =  7'b0100100;
            3: lit =  7'b0110000;
            4: lit =  7'b0011001;
            5: lit =  7'b0010010;
            6: lit =  7'b0000010;
            7: lit =  7'b1111000;
            8: lit =  7'b0000000;
            9: lit =  7'b0010000;
            10: lit = 7'b0001000;
            11: lit = 7'b0000011;
            12: lit = 7'b0100111;
            13: lit = 7'b0100001;
            14: lit = 7'b0000110;
            15: lit = 7'b0001110;
        endcase
    end
endmodule
