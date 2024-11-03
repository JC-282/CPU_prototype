/*
author: Xinyuan Cai
email: cai282@purdue.edu
file type: testbench
description: this is the test bench to test alu file
*/


// mapped needs this
`include "alu_if.vh"
`include "cpu_types_pkg.vh"
// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;
module alu_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  alu_if aluif ();
  // test program
  test PROG (CLK, aluif);
  // DUT
`ifndef MAPPED
  alu DUT (CLK, aluif);
`else
  alu DUT
  (
    .\aluif.negative (aluif.negative),
    .\aluif.overflow (aluif.overflow),
    .\aluif.zero (aluif.zero),
    .\aluif.aluop (aluif.aluop),
    .\aluif.porta (aluif.porta),
    .\aluif.portb (aluif.portb),
    .\aluif.outport (aluif.outport),
    .\CLK (CLK)
  );
`endif

endmodule

program test
(
    input logic CLK,
    alu_if.tb aluif
);
/*
    // RESET task
    task RESET;
    begin
        nRST = 0;
        @(posedge CLK);
        @(posedge CLK);
        @(negedge CLK);

        nRST = 1;
        @(posedge CLK);
        @(posedge CLK);
    end
    endtask
*/
    // Task to send data
    task send_data;
        input aluop_t aluop;
        input word_t porta;
        input word_t portb;
    begin
        aluif.aluop = aluop;
        aluif.porta = porta;
        aluif.portb = portb;
        @(posedge CLK);
    end
    endtask

    // Task to check output
    task check_output;
        input string mess;
        input integer casenum;
        input logic zero;
        input logic negative;
        input logic overflow;
        input word_t outport;
    begin
        if (aluif.zero != zero) begin
            $display("%s case: %d zero_flag value: %d expected: %d", mess, casenum, aluif.zero, zero);
        end
        if (aluif.negative != negative) begin
            $display("%s case: %d negative_flag value: %d expected: %d", mess, casenum, aluif.negative, negative);
        end
        if (aluif.overflow != overflow) begin
            $display("%s case: %d overflow_flag value: %d expected: %d", mess, casenum, aluif.overflow, overflow);
        end
        if (aluif.outport != outport) begin
            $display("%s case: %d output_port value: %h expected: %h", mess, casenum, aluif.outport, outport);
        end
    end
    endtask


    initial
    begin
 //       RESET();
        // **********************zero flag***************************
        send_data(ALU_SUB, 32'hffffffff, 32'hffffffff);
        check_output("zero_flag", 1, 1, 0, 0, 0);
        send_data(ALU_SUB, 32'h0, 32'h0);
        check_output("zero_flag", 2, 1, 0, 0, 0);
        send_data(ALU_ADD, 32'hffffffff, 32'b1);
        check_output("zero_flag", 3, 1, 0, 0, 0);
        send_data(ALU_SRL, 32'h2, 32'b11);
        check_output("zero_flag", 4, 1, 0, 0, 0);
        send_data(ALU_SLL, 32'h2, 32'hc0000000);
        check_output("zero_flag", 5, 1, 0, 0, 0);
        send_data(ALU_SLT, 32'h7fffffff, 32'hffffffff);
        check_output("zero_flag", 6, 1, 0, 0, 0);
        send_data(ALU_SLTU, 32'hfeeeeeee, 32'h0eeeeeee);
        check_output("zero_flag", 7, 1, 0, 0, 0);

        // **********************negative flag***************************
        send_data(ALU_AND, 32'hffffffff, 32'h80000000);
        check_output("neg_flag", 1, 0, 1, 0, 32'h80000000);
        send_data(ALU_OR, 32'b0, 32'hffffffff);
        check_output("neg_flag", 2, 0, 1, 0, 32'hffffffff);
        send_data(ALU_ADD, 32'hfffffffe, 32'h1);
        check_output("neg_flag", 3, 0, 1, 0, 32'hffffffff);
        send_data(ALU_SUB, 32'h7ffffffe, 32'h7fffffff);
        check_output("neg_flag", 4, 0, 1, 0, 32'hffffffff);
        send_data(ALU_XOR, 32'ha5a5a5a5, 32'h5a5a5a5a);
        check_output("neg_flag", 5, 0, 1, 0, 32'hffffffff);
        send_data(ALU_NOR, 32'h0, 32'h0);
        check_output("neg_flag", 6, 0, 1, 0, 32'hffffffff);

        // **********************overflow flag***************************
        send_data(ALU_ADD, 32'h7fffffff, 32'h7fffffff);
        check_output("over_flag", 1, 0, 1, 1, 32'hfffffffe);
        send_data(ALU_ADD, 32'haaaaaaaa, 32'haaaaaaaa);
        check_output("over_flag", 2, 0, 0, 1, 32'h55555554);
        send_data(ALU_ADD, 32'h40000000, 32'h40000000);
        check_output("over_flag", 3, 0, 1, 1, 32'h80000000);
        send_data(ALU_ADD, 32'h80000000, 32'h80000000);
        check_output("over_flag", 4, 1, 0, 1, 32'h0);
        send_data(ALU_SUB, 32'hc0000000, 32'h70000000);
        check_output("over_flag", 5, 0, 0, 1, 32'h50000000);
        send_data(ALU_SUB, 32'hfffffffe, 32'h7fffffff);
        check_output("over_flag", 6, 0, 0, 1, 32'h7fffffff);
        $finish;

    end
endprogram
