// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: vs source file
// description: This is the program counter for pipeline

`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;
module program_counter
(
    input word_t init,
    input logic CLK, nRST, ihit,
    input logic [1:0] jump,
    input logic branchSel,
    input word_t jumpaddr, branchaddr, rdata1,
    output word_t imemaddr, npc,
    input logic stall
);

    word_t nextaddr, b_to_jaddr, n_imemaddr;
    assign npc = imemaddr + 4;
    assign n_imemaddr = (ihit) ? nextaddr : imemaddr;

    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            imemaddr <= init;
        end
        else
        begin
            imemaddr <= n_imemaddr;
        end
    end

    always_comb
    begin
        b_to_jaddr = npc;

        if (branchSel == 0)
        begin
            b_to_jaddr = npc;
        end
        else
        begin
            b_to_jaddr = branchaddr;
        end

        nextaddr = b_to_jaddr;
        if (stall)
        begin
            nextaddr = imemaddr;
        end
        else if (jump == 0)
        begin
            nextaddr = b_to_jaddr;
        end
        else if (jump == 1)
        begin
            nextaddr = jumpaddr;
        end
        else if (jump == 2)
        begin
            nextaddr = rdata1;
        end



    end
endmodule
