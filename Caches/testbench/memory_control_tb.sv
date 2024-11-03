
// email: cai282@purdue.edu
// file type: testbench
// description: this is the testbench to test memory_control.sv file


`include "caches_if.vh"
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"
`include "cpu_types_pkg.vh"

`timescale 1 ns / 1 ns

import cpu_types_pkg::*;
module memory_control_tb;

    parameter PERIOD = 10;
    parameter CPUS = 1;

    logic CLK = 0, nRST;

    always #(PERIOD/2) CLK++;

    //interface
    caches_if cif0();
    caches_if cif1();
    cache_control_if ccif(cif0, cif1);
    cpu_ram_if ramif();
    // test program
    test PROG (CLK, nRST, cif0);
    // DUT
`ifndef MAPPED
    memory_control DUT (CLK, nRST, ccif);
    ram rm (CLK, nRST, ramif);
`else
    memory_control DUT
    (
        .\CLK (CLK),
        .\nRST (nRST),
        .\ccif.iREN (ccif.iREN),
        .\ccif.dREN (ccif.dREN),
        .\ccif.dWEN (ccif.dWEN),
        .\ccif.dstore (ccif.dstore),
        .\ccif.iaddr (ccif.iaddr),
        .\ccif.daddr (ccif.daddr),
        .\ccif.ramload (ccif.ramload),
        .\ccif.ramstate (ccif.ramstate),
        .\ccif.ccwrite (ccif.ccwrite),
        .\ccif.cctrans (ccif.cctrans),
        .\ccif.iwait (ccif.iwait),
        .\ccif.dwait (ccif.dwait),
        .\ccif.iload (ccif.iload),
        .\ccif.dload (ccif.dload),
        .\ccif.ramstore (ccif.ramstore),
        .\ccif.ramaddr (ccif.ramaddr),
        .\ccif.ramWEN (ccif.ramWEN),
        .\ccif.ramREN (ccif.ramREN),
        .\ccif.ccwait (ccif.ccwait),
        .\ccif.ccinv (ccif.ccinv),
        .\ccif.ccsnoopaddr (ccif.ccsnoopaddr)
    );
    ram rm
    (
        .\CLK (CLK),
        .\nRST (nRST),
        .\ramif.ramaddr (ramif.ramaddr),
        .\ramif.ramstore (ramif.ramstore),
        .\ramif.ramREN (ramif.ramREN),
        .\ramif.ramWEN (ramif.ramWEN),
        .\ramif.ramstate (ramif.ramstate),
        .\ramif.ramload (ramif.ramload),
        .\ramif.memREN (ramif.memREN),
        .\ramif.memWEN (ramif.memWEN),
        .\ramif.memaddr (ramif.memaddr),
        .\ramif.memstore (ramif.memstore)
    );
`endif
    always_comb
    begin
        ramif.ramaddr = ccif.ramaddr;
        ramif.ramstore = ccif.ramstore;
        ramif.ramREN = ccif.ramREN;
        ramif.ramWEN = ccif.ramWEN;
        ccif.ramstate = ramif.ramstate;
        ccif.ramload = ramif.ramload;
    end
endmodule

program test
(
    input logic CLK,
    output logic nRST,
    caches_if.caches cif0
);

    parameter PERIOD = 10;
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

    task send_data;
        input logic dREN;
        input logic dWEN;
        input word_t daddr;
        input word_t dstore;
        input logic iREN;
        input word_t iaddr;
    begin
        cif0.dREN = dREN;
        cif0.dWEN = dWEN;
        cif0.daddr = daddr;
        cif0.dstore = dstore;
        cif0.iREN = iREN;
        cif0.iaddr = iaddr;

        @(posedge CLK);
        @(posedge CLK);
        @(negedge CLK);
    end
    endtask
      task automatic dump_memory();
        string filename = "memcpu.hex";
        int memfd;

        cif0.daddr = 0;
        cif0.dWEN = 0;
        cif0.dREN = 0;

        memfd = $fopen(filename,"w");
        if (memfd)
          $display("Starting memory dump.");
        else
          begin $display("Failed to open %s.",filename); $finish; end

        for (int unsigned i = 0; memfd && i < 16384; i++)
        begin
          int chksum = 0;
          bit [7:0][7:0] values;
          string ihex;

          cif0.daddr = i << 2;
          cif0.dREN = 1;
          repeat (4) @(posedge CLK);
          if (cif0.dload === 0)
            continue;
          values = {8'h04,16'(i),8'h00,cif0.dload};
          foreach (values[j])
            chksum += values[j];
          chksum = 16'h100 - chksum;
          ihex = $sformatf(":04%h00%h%h",16'(i),cif0.dload,8'(chksum));
          $fdisplay(memfd,"%s",ihex.toupper());
        end //for
        if (memfd)
        begin
          cif0.dREN = 0;
          $fdisplay(memfd,":00000001FF");
          $fclose(memfd);
          $display("Finished memory dump.");
        end
      endtask

    initial
    begin
        RESET();
        // instruction read
        send_data(0, 0, 0, 0, 1, 32'h0000);
        if (cif0.iload != 32'h341D0000) begin
            $display("case 1: iload = %h, expected = 32'h341D0000", cif0.iload);
        end

        // data read
        send_data(1, 0, 32'h0000, 0, 0, 0);
        if (cif0.dload != 32'h341D0000) begin
            $display("case 2: dload = %h, expected = 32'h341D0000", cif0.dload);
        end

        // instuction read
        send_data(0, 0, 0, 0, 1, 32'h0054);
        if (cif0.iload != 32'hFFFFFFFF) begin
            $display("case 3: iload = %h, expected = 32'hFFFFFFFF", cif0.iload);
        end

        // enable instruction and data read at the same time
        send_data(1, 0, 32'h0054, 0, 1, 0);
        if (cif0.dload != 32'hFFFFFFFF) begin
            $display("case 4: dload = %h, expected = 32'hFFFFFFFF", cif0.dload);
        end

        // send the data and read the data from specific memory
        send_data(0, 1, 1999, 1128, 0, 0);
        send_data(1, 0, 1999, 0, 0, 0);
        if (cif0.dload != 1128) begin
            $display("case 5: dload = %d, expected = 1128", cif0.dload);
        end
        dump_memory();
        $finish;
   end
endprogram
