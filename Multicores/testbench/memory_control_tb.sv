
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
    parameter CPUS = 2;

    logic CLK = 0, nRST;

    always #(PERIOD/2) CLK++;

    //interface
    caches_if cif0();
    caches_if cif1();
    cache_control_if ccif(cif0, cif1);
    cpu_ram_if ramif();
    system_if syif();

    // test program
    test PROG (CLK, nRST, cif0, cif1);
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
        .\ramif.ramload (ramif.ramload)
        /*
        .\ramif.memREN (ramif.memREN),
        .\ramif.memWEN (ramif.memWEN),
        .\ramif.memaddr (ramif.memaddr),
        .\ramif.memstore (ramif.memstore)
        */
    );
`endif
    always_comb
    begin
        syif.load = ramif.ramload;
        ramif.ramaddr = syif.tbCTRL ? syif.addr : ccif.ramaddr;
        ramif.ramstore = syif.tbCTRL ? syif.store : ccif.ramstore;
        ramif.ramREN = syif.tbCTRL ? syif.REN : ccif.ramREN;
        ramif.ramWEN = syif.tbCTRL ? syif.WEN : ccif.ramWEN;
        ccif.ramstate = ramif.ramstate;
        ccif.ramload = ramif.ramload;
    end
endmodule

program test
(
    input logic CLK,
    output logic nRST,
    caches_if.caches cif0,
    caches_if.caches cif1
);
    logic snoophit0, snoophit1;
    parameter PERIOD = 10;
    // RESET task
    task RESET;
    begin
        nRST = 0;
        syif.tbCTRL = 0;
        send_data0(0,0,0,0,0,0,0,0);
        send_data1(0,0,0,0,0,0,0,0);
        @(posedge CLK);
        @(posedge CLK);
        @(negedge CLK);

        nRST = 1;
        @(posedge CLK);
        @(posedge CLK);
    end
    endtask

    task send_data0;
        input logic dREN;
        input logic dWEN;
        input word_t daddr;
        input word_t dstore;
        input logic ccwrite;
        input logic cctrans;
        input logic iREN;
        input word_t iaddr;
    begin
        cif0.dREN = dREN;
        cif0.dWEN = dWEN;
        cif0.daddr = daddr;
        cif0.dstore = dstore;
        cif0.iREN = iREN;
        cif0.iaddr = iaddr;
        cif0.ccwrite = ccwrite;
        cif0.cctrans = cctrans;
    end

    endtask

    task send_data1;
        input logic dREN;
        input logic dWEN;
        input word_t daddr;
        input word_t dstore;
        input logic ccwrite;
        input logic cctrans;
        input logic iREN;
        input word_t iaddr;
    begin
        cif1.dREN = dREN;
        cif1.dWEN = dWEN;
        cif1.daddr = daddr;
        cif1.dstore = dstore;
        cif1.iREN = iREN;
        cif1.iaddr = iaddr;
        cif1.ccwrite = ccwrite;
        cif1.cctrans = cctrans;
    end
    endtask

    task check0;
        input string tag;
        input logic ex_dwait;
        input word_t ex_dload;
        input logic ex_ccwait;
        input logic ex_ccinv;
        input word_t ex_ccsnoopaddr;
        input logic ex_iwait;
        input word_t ex_iload;
    begin
        if(cif0.dwait != ex_dwait)
            $display("For %s, dwait is incorrect, it should be %h, but it is %h", tag, ex_dwait, cif0.dwait);
        if(cif0.dload != ex_dload)
            $display("For %s, dload is incorrect, it should be %h, but it is %h", tag, ex_dload, cif0.dload);
        if(cif0.ccwait != ex_ccwait)
            $display("For %s, ccwait is incorrect, it should be %h, but it is %h", tag, ex_ccwait, cif0.ccwait);
        if(cif0.ccinv != ex_ccinv)
            $display("For %s, ccinvis incorrect, it should be %h, but it is %h", tag, ex_ccinv,cif0.ccinv);
        if(cif0.ccsnoopaddr != ex_ccsnoopaddr)
            $display("For %s, ccsnoopaddr is incorrect, it should be %h, but it is %h", tag, ex_ccsnoopaddr, cif0.ccsnoopaddr);
        if(cif0.iwait != ex_iwait)
            $display("For %s, iwait is incorrect, it should be %h, but it is %h", tag, ex_iwait, cif0.iwait);
        if(cif0.iload != ex_iload)
            $display("For %s, iload is incorrect, it should be %h, but it is %h", tag, ex_iload, cif0.iload);
    end
    endtask

    task check1;
        input string tag;
        input logic ex_dwait;
        input word_t ex_dload;
        input logic ex_ccwait;
        input logic ex_ccinv;
        input word_t ex_ccsnoopaddr;
        input logic ex_iwait;
        input word_t ex_iload;
    begin
        if(cif1.dwait != ex_dwait)
            $display("For %s, dwait is incorrect, it should be %h, but it is %h", tag, ex_dwait, cif1.dwait);
        if(cif1.dload != ex_dload)
            $display("For %s, dload is incorrect, it should be %h, but it is %h", tag, ex_dload, cif1.dload);
        if(cif1.ccwait != ex_ccwait)
            $display("For %s, ccwait is incorrect, it should be %h, but it is %h", tag, ex_ccwait, cif1.ccwait);
        if(cif1.ccinv != ex_ccinv)
            $display("For %s, ccinvis incorrect, it should be %h, but it is %h", tag, ex_ccinv,cif1.ccinv);
        if(cif1.ccsnoopaddr != ex_ccsnoopaddr)
            $display("For %s, ccsnoopaddr is incorrect, it should be %h, but it is %h", tag, ex_ccsnoopaddr, cif1.ccsnoopaddr);
        if(cif1.iwait != ex_iwait)
            $display("For %s, iwait is incorrect, it should be %h, but it is %h", tag, ex_iwait, cif1.iwait);
        if(cif1.iload != ex_iload)
            $display("For %s, iload is incorrect, it should be %h, but it is %h", tag, ex_iload, cif1.iload);
    end
    endtask

    task w_s;
        input logic signal;
        begin
        while (signal != 0);

        end
    endtask

  task automatic dump_memory();
    string filename = "memcpu.hex";
    int memfd;

    syif.tbCTRL = 1;
    syif.addr = 0;
    syif.WEN = 0;
    syif.REN = 0;

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

      syif.addr = i << 2;
      syif.REN = 1;
      repeat (4) @(posedge CLK);
      if (syif.load === 0)
        continue;
      values = {8'h04,16'(i),8'h00,syif.load};
      foreach (values[j])
        chksum += values[j];
      chksum = 16'h100 - chksum;
      ihex = $sformatf(":04%h00%h%h",16'(i),syif.load,8'(chksum));
      $fdisplay(memfd,"%s",ihex.toupper());
    end //for
    if (memfd)
    begin
      syif.tbCTRL = 0;
      syif.REN = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
  endtask

    initial
    begin
        RESET();
        //based on merge sort
        //i read
        //cif0 read
        send_data0(0,0,0,0,0,0,1,32'h12*4);
        send_data1(0,0,0,0,0,0,0,32'h12*4);
        @(negedge cif0.iwait);
        check0("single read 0_0",1,0,0,0,0,0,32'h0c00001d);
        check1("single read 0_1",1,0,0,0,0,1,0);
        //cif1 read
        @(posedge CLK);
        send_data0(0,0,0,0,0,0,0,32'h12*4);
        send_data1(0,0,0,0,0,0,1,32'hEF*4);
        @(negedge cif1.iwait);
        check0("single read 1_0",1,0,0,0,0,1,0);
        check1("single read 1_1",1,0,0,0,0,0,32'h00000044);
        //both read
        @(posedge CLK);
        send_data0(0,0,0,0,0,0,1,32'h22*4);
        send_data1(0,0,0,0,0,0,1,32'hEF*4);
        @(negedge cif0.iwait);
        check0("single read 1_0",1,0,0,0,0,0,32'h0088c821);
        check1("single read 1_1",1,0,0,0,0,1,32'h00000000);
        @(posedge CLK);

        //flush
        //cif1 flush
        send_data0(0,0,0,0,0,0,0,0);
        send_data1(0,1,32'h101*4,32'h578c,0,0,0,0);
        @(negedge cif1.dwait);
        @(posedge CLK);
        send_data1(0,1,32'h102*4,32'h578d,0,0,0,0);
        @(negedge cif1.dwait);
        @(posedge CLK);
        //cif0 flush
        send_data1(0,0,0,0,0,0,0,0);
        send_data0(0,1,32'h103*4,32'h578c,0,0,0,0);
        @(negedge cif0.dwait);
        @(posedge CLK);
        send_data0(0,1,32'h104*4,32'h578d,0,0,0,0);
        @(negedge cif0.dwait);
        @(posedge CLK);
        //both flush
        send_data1(0,1,32'h105*4,32'h578c,0,0,0,0);
        send_data0(0,1,32'h110*4,32'h578c,0,0,0,0);
        @(negedge cif0.dwait);
        @(posedge CLK);
        send_data1(0,1,32'h106*4,32'h578d,0,0,0,0);
        send_data0(0,1,32'h111*4,32'h578d,0,0,0,0);
        @(negedge cif0.dwait);
        @(posedge CLK);

        //busread hit
        //cif1 read
        send_data1(1,0,32'h101*4,0,0,1,0,0);
        send_data0(0,0,0,0,(0),0,0,0);
        @(posedge CLK);
        send_data1(1,0,32'h101*4,0,0,1,0,0);
        send_data0(0,0,0,32'h1111,(cif0.ccsnoopaddr == 32'h101*4),1,0,0);
        @(negedge cif1.dwait);
        check1("read snoop hit 0_0",0,32'h1111, 1,0,32'h101*4,1,0);
        check0("read snoop hit 1_0",0,0,1,0,32'h101*4,1,0);

        @(posedge CLK);
        send_data1(1,0,32'h102*4,0,0,1,0,0);
        send_data0(0,0,0,32'h2222,(1),1,0,0);
        @(negedge cif1.dwait);
        check1("read snoop hit 0_1",0,32'h2222, 1,0,32'h102*4,1,0);
        check0("read snoop hit 1_1",0,0,1,0,32'h102*4,1,0);

        @(posedge CLK);
        send_data1(0,0,0,0,0,0,0,0);
        send_data0(0,0,0,0,0,0,0,0);
        @(posedge CLK);

        //both read
        send_data0(1,0,32'h120*4,0,0,1,0,0);
        send_data1(1,0,32'h121*4,0,0,1,0,0);
        @(posedge CLK);
        send_data0(1,0,32'h120*4,32'h3333,(cif0.ccsnoopaddr == 32'h121*4),1,0,0);
        send_data1(1,0,32'h121*4,32'h4444,(cif1.ccsnoopaddr == 32'h120*4),1,0,0);
        @(negedge cif0.dwait);
        check0("both read snoop hit 0_0",0,32'h4444, 1,0,32'h120*4,1,0);
        check1("both read snoop hit 1_0",0,0,1,0,32'h120*4,1,0);

        @(posedge CLK);
        send_data0(1,0,32'h124*4,32'h3333,1,1,0,0);
        send_data1(1,0,32'h125*4,32'h4444,(1),1,0,0);
        @(negedge cif0.dwait);
        check0("both read snoop hit 0_1",0,32'h4444, 1,0,32'h124*4,1,0);
        check1("both read snoop hit 1_1",0,0,1,0,32'h124*4,1,0);

        @(posedge CLK);
        send_data0(0,0,0,0,0,0,0,0);
        send_data1(0,0,0,0,0,0,0,0);

        @(posedge CLK);



        //busread not hit
        //cif1 read
        send_data1(1,0,32'h101*4,0,0,1,0,0);
        send_data0(0,0,0,0,(0),0,0,0);
        @(posedge CLK);
        send_data1(1,0,32'h101*4,0,0,1,0,0);
        send_data0(0,0,0,32'h1111,(cif0.ccsnoopaddr != 32'h101*4),1,0,0);
        @(negedge cif1.dwait);
        check1("read snoop not hit 0_0",0,32'h1111, 1,0,32'h101*4,1,0);
        check0("read snoop not hit 1_0",1,0,1,0,32'h101*4,1,0);

        @(posedge CLK);
        send_data1(1,0,32'h102*4,0,0,1,0,0);
        send_data0(0,0,0,32'h2222,(1),1,0,0);
        @(negedge cif1.dwait);
        check1("read snoop not hit 0_1",0,32'h2222, 1,0,32'h102*4,1,0);
        check0("read snoop not hit 1_1",1,0,1,0,32'h102*4,1,0);

        @(posedge CLK);
        send_data1(0,0,0,0,0,0,0,0);
        send_data0(0,0,0,0,0,0,0,0);
        @(posedge CLK);

        //both read
        send_data0(1,0,32'h120*4,0,0,1,0,0);
        send_data1(1,0,32'h121*4,0,0,1,0,0);
        @(posedge CLK);
        send_data0(1,0,32'h120*4,32'h3333,(cif0.ccsnoopaddr != 32'h121*4),1,0,0);
        send_data1(1,0,32'h121*4,32'h4444,(cif1.ccsnoopaddr != 32'h120*4),1,0,0);
        @(negedge cif0.dwait);
        check0("both read snoop not hit 0_0",0,32'h4444, 1,0,32'h120*4,1,0);
        check1("both read snoop not hit 1_0",1,0,1,0,32'h120*4,1,0);

        @(posedge CLK);
        send_data0(1,0,32'h124*4,32'h3333,1,1,0,0);
        send_data1(1,0,32'h125*4,32'h4444,(1),1,0,0);
        @(negedge cif0.dwait);
        check0("both read snoop not hit 0_1",0,32'h4444, 1,0,32'h124*4,1,0);
        check1("both read snoop not hit 1_1",1,0,1,0,32'h124*4,1,0);

        @(posedge CLK);
        send_data0(0,0,0,0,0,0,0,0);
        send_data1(0,0,0,0,0,0,0,0);

        @(posedge CLK);



        //busread and write hit
        //cif1 read
        send_data1(1,0,32'h101*4,0,1,1,0,0);
        send_data0(0,0,0,0,(0),0,0,0);
        @(posedge CLK);
        send_data1(1,0,32'h101*4,0,0,1,0,0);
        send_data0(0,0,0,32'h1111,(cif0.ccsnoopaddr == 32'h101*4),1,0,0);
        @(negedge cif1.dwait);
        check1("r&w snoop hit 1_0",0,32'h1111, 1,0,32'h101*4,1,0);
        check0("r&w snoop hit 0_0",1,0,1,1,32'h101*4,1,0);

        send_data1(1,0,32'h102*4,0,0,1,0,0);
        send_data0(0,0,0,32'h2222,(1),1,0,0);
        @(posedge CLK);
        check1("r&w snoop hit 1_1",0,32'h2222, 1,0,32'h102*4,1,0);
        check0("r&w snoop hit 0_1",1,0,1,1,32'h102*4,1,0);

        @(posedge CLK);
        send_data1(1,0,32'h102*4,0,1,1,0,0);
        send_data0(0,0,0,0,0,0,0,0);
        @(posedge CLK);
        check1("r&w snoop hit 1_2",0,0,1,0,32'h102*4,1,0);
        check0("r&w snoop hit 0_2",1,0,1,1,32'h102*4,1,0);
        send_data1(0,0,0,0,0,0,0,0);
        @(posedge CLK);


        //both read
        send_data0(1,0,32'h101*4,0,1,1,0,0);
        send_data1(1,0,32'h102*4,0,1,1,0,0);
        @(posedge CLK);
        send_data0(1,0,32'h101*4,0,0,1,0,0);
        send_data1(1,0,0,32'h1111,(cif1.ccsnoopaddr == 32'h101*4),1,0,0);
        @(negedge cif0.dwait);
        check0("r&w snoop hit 0_0",0,32'h1111, 1,0,32'h101*4,1,0);
        check1("r&w snoop hit 1_0",1,0,1,1,32'h101*4,1,0);

        send_data0(1,0,32'h102*4,0,0,1,0,0);
        send_data1(1,0,0,32'h2222,(1),1,0,0);
        @(posedge CLK);
        check0("r&w snoop hit 0_1",0,32'h2222, 1,0,32'h102*4,1,0);
        check1("r&w snoop hit 1_1",1,0,1,1,32'h102*4,1,0);

        @(posedge CLK);
        send_data0(1,0,32'h102*4,0,1,1,0,0);
        send_data1(1,0,32'h102*4,0,1,0,0,0);
        @(posedge CLK);
        check0("r&w snoop hit 0_2",0,0,1,0,32'h102*4,1,0);
        check1("r&w snoop hit 1_2",1,0,1,1,32'h102*4,1,0);
        send_data0(0,0,0,0,0,0,0,0);
        @(posedge CLK);

        //busread and write not hit
        //cif1 read
        send_data1(1,0,32'h101*4,0,1,1,0,0);
        send_data0(0,0,0,0,(0),0,0,0);
        @(posedge CLK);
        send_data1(1,0,32'h101*4,0,0,1,0,0);
        send_data0(0,0,0,32'h1111,(cif0.ccsnoopaddr != 32'h101*4),1,0,0);//when ccwait high,ccwrite represent snoop hit
        @(posedge CLK);
        send_data1(1,0,32'h101*4,0,1,1,0,0);
        send_data0(0,0,0,0,0,0,0,0);

        check1("r&w snoop not hit 1_0",1,0,1,0,32'h101*4,1,0);
        check0("r&w snoop not hit 0_0",1,0,1,1,32'h101*4,1,0);
        @(negedge cif1.dwait);
        check1("r&w snoop not hit 1_1",0,32'h1111, 1,0,32'h101*4,1,0);
        check0("r&w snoop not hit 0_1",1,0,1,0,32'h101*4,1,0);

        send_data1(1,0,32'h102*4,0,0,1,0,0);
        send_data0(0,0,0,32'h2222,(1),1,0,0);
        @(negedge cif1.dwait);
        check1("r&w snoop not hit 1_2",0,32'h2222, 1,0,32'h102*4,1,0);
        check0("r&w snoop not hit 0_2",1,0,1,0,32'h102*4,1,0);

        send_data1(0,0,0,0,0,0,0,0);
        @(posedge CLK);
RESET();

        //both read
        send_data0(1,0,32'h101*4,0,1,1,0,0);
        send_data1(1,0,32'h103*4,0,1,1,0,0);
        @(posedge CLK);
        send_data0(1,0,32'h101*4,0,0,1,0,0);
        send_data1(1,0,0,32'h1111,(cif1.ccsnoopaddr != 32'h101*4),1,0,0);
        @(posedge CLK);
        send_data0(1,0,32'h101*4,0,1,1,0,0);
        send_data1(1,0,32'h103*4,0,1,0,0,0);

        check0("r&w snoop not hit 0_0",1,0,1,0,32'h101*4,1,0);
        check1("r&w snoop not hit 1_0",1,0,1,1,32'h101*4,1,0);
        @(negedge cif0.dwait);
        check0("r&w snoop not hit 0_1",0,32'h1111, 1,0,32'h101*4,1,0);
        check1("r&w snoop not hit 1_1",1,0,1,0,32'h101*4,1,0);

        send_data0(1,0,32'h102*4,0,0,1,0,0);
        send_data1(0,0,0,32'h2222,(1),1,0,0);
        @(negedge cif0.dwait);
        check0("r&w snoop not hit 0_2",0,32'h2222, 1,0,32'h102*4,1,0);
        check1("r&w snoop not hit 1_2",1,0,1,0,32'h102*4,1,0);

        send_data0(0,0,0,0,0,0,0,0);
        @(posedge CLK);

















        nRST = 0;
        dump_memory();
        $finish;
   end
endprogram
