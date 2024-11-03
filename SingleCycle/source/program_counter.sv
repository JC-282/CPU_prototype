// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: source vs file
// description: this is the source sv file for program counter

`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"

import cpu_types_pkg::*;

module program_counter
(
    input logic CLK, nRST,
    input logic ihit, zero,
    input word_t imme, data1,
    input logic [25:0] jaddr, //imemload[25:0]
    output word_t imemaddr, npc,
    control_unit_if.pc pcif
);

    logic branchSel;
    logic [27:0] s_jaddr; // shift address for jump mux
    word_t n_imemaddr; // for flip_flop
    word_t nextaddr; // result after complicated mux
    word_t j_addr; // jump address
    word_t b_addr; // branch address
    word_t s_baddr; // shift address for branch mux
    word_t result_b_addr; // result address after branch mux

    // branchSel signal logic
    assign branchSel = (pcif.branch == 1 && zero == 1 ||
                        pcif.branch == 2 && zero == 0) ? 1 : 0;

    // next imemaddr logic
    assign n_imemaddr = (ihit) ? nextaddr : imemaddr;

    assign npc = imemaddr + 4;

    assign s_jaddr = jaddr << 2;
    assign j_addr = {npc[31:28], s_jaddr};

    assign s_baddr = imme << 2;
    assign b_addr = s_baddr + npc;

    assign result_b_addr = (branchSel) ? b_addr : npc;

    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            imemaddr <= 0;
        end
        else
        begin
            imemaddr <= n_imemaddr;
        end
    end

    always_comb
    begin
        nextaddr = result_b_addr;
        if (pcif.jump == 0)
        begin
            nextaddr = result_b_addr;
        end
        else if (pcif.jump == 1)
        begin
            nextaddr = j_addr;
        end
        else if (pcif.jump == 2)
        begin
            nextaddr = data1;
        end
    end
endmodule

