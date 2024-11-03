// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type:test bench
// description: test bench for icache
`include "datapath_cache_if.vh"
`include "caches_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
`timescale 1 ns / 1 ns
module icache_tb;
    parameter PERIOD = 10;

    logic CLK = 0, nRST;

    // clock
    always #(PERIOD/2) CLK++;

    // interface
    datapath_cache_if dcif ();
    caches_if cif ();

    test PROG(CLK,nRST,dcif,cif.iREN, cif.iaddr,cif.iwait, cif.iload);

    `ifndef MAPPED
        icache DUT (CLK,nRST,dcif,cif);
    `else
        icache DUT
        (
            .\CLK (CLK),
            .\nRST (nRST),
            .\dcifi.imemREN (dcif.imemREN),
            .\dcifi.imemaddr (dcif.imemaddr),
            .\dcifi.ihit (dcif.ihit),
            .\dcifi.imemload (dcif.imemload),
            .\cifi.iwait (cif.iwait),
            .\cifi.iload (cif.iload),
            .\cifi.iREN (cif.iREN),
            .\cifi.iaddr (cif.iaddr)
        );
    `endif
endmodule

program test
(
    input logic CLK,
    output logic nRST,
    datapath_cache_if.dp dpif,
    input logic iREN,
    input word_t iaddr,
    output logic iwait,
    output word_t iload
);
    logic [3:0] idx;
    //tags
    logic[25:0] tag1, tag2;
    assign tag1 = 26'h10086;
    assign tag2 = 26'h10010;
task RESET;
    begin
        nRST = 0;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);

        nRST = 1;
        @(posedge CLK);
        @(posedge CLK);
    end
endtask

task check;
    input string tag;
    input logic exp_iREN;
    input word_t exp_iaddr;
    input logic exp_ihit;
    input word_t exp_imemload;
    begin
        #(2);
        if(iREN != exp_iREN)
            $display("For case %s, iREN is incorrect. it should be %h, but it is %h", tag, exp_iREN,iREN);
        if(iaddr != exp_iaddr)
            $display("For case %s, iaddr is incorrect. it should be %h, but it is %h", tag, exp_iaddr,iaddr);
        if(dpif.ihit != exp_ihit)
            $display("For case %s, ihit is incorrect. it should be %h, but it is %h", tag,exp_ihit,dpif.ihit);
        if(dpif.imemload != exp_imemload)
            $display("For case %s, imemload is incorrect. it should be %h, but it is %h", tag, exp_imemload,dpif.imemload);
    end

endtask

initial
begin
    iwait = 1;
    iload = '0;
    dpif.imemREN = 0;
    dpif.imemaddr = '0;
    //reset state
    RESET();
    check("reset",'0,'0,'0,'0);
    for(int i = 0; i < 16; i++)
    begin
        idx = i;
        //compulsory miss
        dpif.imemREN = 1;
        dpif.imemaddr = word_t'({tag1,idx,2'b0});
        check("comp 1",0,'0,0,'0);
        @(posedge CLK);
        check("comp 2",1,word_t'({tag1,idx,2'b0}),0,'0);

        // next three clock is to mock the memory latency
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        iwait = 0;
        iload = word_t'(32'haaaa);

        @(posedge CLK);
        iwait = 1;
        check("comp miss->hit",0,'0,1,word_t'(32'haaaa));
    end
    //conflict miss
    for(int j = 0; j < 16; j++)
    begin
        idx = j;
        //compulsory miss
        dpif.imemREN = 1;
        dpif.imemaddr = word_t'({tag2,idx,2'b0});
        check("conflict 1",0,'0,0,word_t'(32'haaaa));
        @(posedge CLK);
        check("conflict 2",1,word_t'({tag2,idx,2'b0}),0,word_t'(32'haaaa));

        // next three clock is to mock the memory latency
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        iwait = 0;
        iload = word_t'(32'habab);

        @(posedge CLK);
        iwait = 1;
        check("cconflict miss->hit",0,'0,1,word_t'(32'habab));
    end
    //hit
    for(int k = 0; k < 16; k++)
    begin
        idx = k;
        //compulsory miss
        dpif.imemREN = 0;
        dpif.imemaddr = word_t'({tag2,idx,2'b0});
        check("hit 1",0,'0,1,word_t'(32'habab));
        @(posedge CLK);
    end
    $finish;
end
endprogram
