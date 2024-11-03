// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type:test bench
// description:test bench for dcache
`include "datapath_cache_if.vh"
`include "caches_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
`timescale 1 ns / 1 ns
module dcache_tb;
    parameter PERIOD = 10;

    logic CLK = 0, nRST;

    // clock
    always #(PERIOD/2) CLK++;

    // interface
    datapath_cache_if dcif ();
    caches_if cif ();

    test PROG
        (CLK,nRST,dcif,dcif.flushed,
        cif.dREN,cif.dWEN,cif.daddr,cif.dstore,
        cif.dwait,cif.dload
        );

    `ifndef MAPPED
        dcache DUT (CLK,nRST,dcif,cif);
    `else
        dcache DUT
        (
            .\CLK (CLK),
            .\nRST (nRST),
            .\dcifd.halt (dcif.halt),
            .\dcifd.dmemREN (dcif.dmemREN),
            .\dcifd.dmemWEN (dcif.dmemWEN),
            .\dcifd.dmemstore (dcif.dmemstore),
            .\dcifd.dmemaddr (dcif.dmemaddr),
            .\dcifd.dhit (dcif.dhit),
            .\dcifd.dmemload (dcif.dmemload),
            .\dcifd.flushed (dcif.flushed),
            .\cifd.dwait (cif.dwait),
            .\cifd.dload (cif.dload),
            .\cifd.dREN (cif.dREN),
            .\cifd.dWEN (cif.dWEN),
            .\cifd.daddr (cif.daddr),
            .\cifd.dstore (cif.dstore)
        );
    `endif
endmodule

program test
(
    input logic CLK,
    output logic nRST,
    datapath_cache_if.dp dpif,
    input logic flushed,
    input logic dREN, dWEN,
    input word_t daddr,dstore,
    output logic dwait,
    output word_t dload
);
    logic [25:0] tag1, tag2, tag3;
    assign tag1 = 26'h10086;
    assign tag2 = 26'h10010;
    assign tag3 = 26'h5d78d;
    logic [2:0] ind;
    string test_tag;
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
    //to mem
    input logic exp_dREN;
    input logic exp_dWEN;
    input word_t exp_daddr;
    input word_t exp_dstore;
    //to datapath
    input logic exp_dhit;
    input word_t exp_dmemload;
    input logic exp_flushed;
    begin
        #(2);
        if (exp_flushed != 1)
        begin
            if(dREN != exp_dREN)
                $display("For case %s, dREN is incorrect. it should be %h, but it is %h", tag, exp_dREN,dREN);
            if(dWEN != exp_dWEN)
                $display("For case %s, dWEN is incorrect. it should be %h, but it is %h", tag, exp_dWEN,dWEN);
            if(daddr != exp_daddr)
                $display("For case %s, daddr is incorrect. it should be %h, but it is %h", tag, exp_daddr,daddr);
            if(dstore != exp_dstore)
                $display("For case %s, dstore is incorrect. it should be %h, but it is %h", tag,exp_dstore,dstore);
            if(dpif.dhit != exp_dhit)
                $display("For case %s, dhit is incorrect. it should be %h, but it is %h", tag, exp_dhit,dpif.dhit);
            if(dpif.dmemload != exp_dmemload && dpif.dhit == 1)
                $display("For case %s, dmemload is incorrect. it should be %h, but it is %h", tag, exp_dmemload,dpif.dmemload);
        end
        else
        begin
            if(flushed != exp_flushed)
                $display("For case %s, flushed is incorrect. it should be %h, but it is %h", tag, exp_flushed,flushed);
        end
    end


endtask
initial
begin

    dwait = 1;
    dload = 0;
    dcif.halt = 0;
    dcif.dmemREN = 0;
    dcif.dmemWEN = 0;
    dcif.dmemstore = '0;
    dcif.dmemaddr = '0;

    //reset
    RESET();
    check("reset",0,0,'0,'0,0,'0,0);

    for (int i = 0; i < 8; i++)
    begin
        ind = i;
        //compulsory miss
        dcif.dmemREN = 1;
        dcif.dmemaddr = word_t'({tag1,ind,3'b0});
        @(posedge CLK);
        check("comp miss 1",1,0, word_t'({tag1,ind,3'b0}), '0, 0, '0, 0);
        //mock mem latency
        @(posedge CLK);
        check("comp miss 1",1,0, word_t'({tag1,ind,3'b0}), '0, 0, '0, 0);
        @(posedge CLK);
        check("comp miss 1",1,0, word_t'({tag1,ind,3'b0}), '0, 0, '0, 0);
        @(posedge CLK);
        check("comp miss 1",1,0, word_t'({tag1,ind,3'b0}), '0, 0, '0, 0);
        dwait = 0;
        dload = 32'haaaa+i;
        @(posedge CLK);
        dwait = 1;

        check("comp miss 1",1,0, word_t'({tag1,ind,3'b100}), '0, 0, '0, 0);

        @(posedge CLK);
        check("comp miss 1",1,0, word_t'({tag1,ind,3'b100}), '0, 0, '0, 0);
        @(posedge CLK);
        check("comp miss 1",1,0, word_t'({tag1,ind,3'b100}), '0, 0, '0, 0);
        @(posedge CLK);
        check("comp miss 1",1,0, word_t'({tag1,ind,3'b100}), '0, 0, '0, 0);
        dwait = 0;
        dload = 32'habab+i;
        @(posedge CLK);
        //@(posedge CLK);

        check("comp miss 2",0,0, '0, '0, 1, 32'haaaa+i, 0);
        dcif.dmemaddr = word_t'({tag1,ind,3'b100});
        check("comp miss 3",0,0, '0, '0, 1, 32'habab+i, 0);
        dcif.dmemREN = 0;
        dwait = 1;

        // the other half
        dcif.dmemREN = 1;
        dcif.dmemaddr = word_t'({tag2,ind,3'b100});
        @(posedge CLK);
        check("comp miss 2.1",1,0, word_t'({tag2,ind,3'b0}), '0, 0, '0, 0);
        //mock mem latency
        @(posedge CLK);
        check("comp miss 2.1",1,0, word_t'({tag2,ind,3'b0}), '0, 0, '0, 0);
        @(posedge CLK);
        check("comp miss 2.1",1,0, word_t'({tag2,ind,3'b0}), '0, 0, '0, 0);
        @(posedge CLK);
        check("comp miss 2.1",1,0, word_t'({tag2,ind,3'b0}), '0, 0, '0, 0);
        dwait = 0;
        dload = 32'hcccc+i;
        @(posedge CLK);
        dwait = 1;
        check("comp miss 2.1",1,0, word_t'({tag2,ind,3'b100}), '0, 0, '0, 0);

        @(posedge CLK);
        check("comp miss 2.1",1,0, word_t'({tag2,ind,3'b100}), '0, 0, '0, 0);
        @(posedge CLK);
        check("comp miss 2.1",1,0, word_t'({tag2,ind,3'b100}), '0, 0, '0, 0);
        @(posedge CLK);
        check("comp miss 2.1",1,0, word_t'({tag2,ind,3'b100}), '0, 0, '0, 0);
        dwait = 0;
        dload = 32'hcdcd+i;
        @(posedge CLK);
        //@(posedge CLK);

        dcif.dmemaddr = word_t'({tag2,ind,3'b000});
        check("comp miss 2.2",0,0, '0, '0, 1, 32'hcccc+i, 0);
        dcif.dmemaddr = word_t'({tag2,ind,3'b100});
        check("comp miss 2.3",0,0, '0, '0, 1, 32'hcdcd+i, 0);
        dcif.dmemREN = 0;
        dwait = 1;
    end
    // write when hit

    for (int i = 0; i < 4; i++)
    begin
        // the other half
        ind = i;
        dcif.dmemWEN = 1;
        //dmemStore = 32'h00aa + i;
        dcif.dmemaddr = word_t'({tag1,ind,3'b0});
        dcif.dmemstore = 32'b0 + i;
        @(posedge CLK);
        @(posedge CLK);
        check("write LW when hit 2.2",0,0, '0, '0, 1, 32'h0+i, 0);
        dcif.dmemaddr = word_t'({tag1,ind,3'b100});
        check("write LW when hit 2.3",0,0, '0, '0, 1, 32'habab+i, 0);
        dcif.dmemWEN = 0;
        @(posedge CLK);
        check("write when hit 2.2",0,0, '0, '0, 0, 32'h0+i, 0);
        dcif.dmemaddr = word_t'({tag1,ind,3'b100});
        check("write when hit 2.3",0,0, '0, '0, 0, 32'habab+i, 0);
        dcif.dmemWEN = 0;
        @(posedge CLK);
    end

    for (int i = 4; i < 8; i++)
    begin
        // the other half
        ind = i;
        dcif.dmemWEN = 1;
        //dmemStore = 32'h00aa + i;
        dcif.dmemaddr = word_t'({tag2,ind,3'b100});
        dcif.dmemstore = 32'b0 + i;
        @(posedge CLK);
        @(posedge CLK);
        check("write LW when hit 3.2",0,0, '0, '0, 1, 32'h0+i, 0);
        dcif.dmemaddr = word_t'({tag2,ind,3'b000});
        check("write LW when hit 3.3",0,0, '0, '0, 1, 32'hcccc+i, 0);
        dcif.dmemWEN = 0;
        @(posedge CLK);
        check("write when hit 3.2",0,0, '0, '0, 0, 32'hcccc+i, 0);
        dcif.dmemaddr = word_t'({tag2,ind,3'b100});
        check("write when hit 3.3",0,0, '0, '0, 0, 32'h0+i, 0);
        dcif.dmemWEN = 0;
        @(posedge CLK);
    end

    //tag match but dirty
    //read
    @(posedge CLK);
    dcif.dmemREN = 1;
    dcif.dmemaddr = word_t'({tag1,3'b0,3'b0});
    check("dirty match read 1",0,0, '0, '0, 1, 32'h0, 0);
    @(posedge CLK);
    dcif.dmemaddr = word_t'({tag1,3'b1,3'b100});
    check("dirty match read 2",0,0, '0, '0, 1, 32'habab+1, 0);
    dcif.dmemREN = 0;
    //write
    @(posedge CLK);
    dcif.dmemWEN = 1;
    dcif.dmemaddr = word_t'({tag1,3'd2,3'b0});
    dcif.dmemstore = 32'habcd;
    @(posedge CLK);
    @(posedge CLK);
    check("dirty match write 1.1",0,0, '0, '0, 1, 32'habcd, 0);
    dcif.dmemaddr = word_t'({tag1,3'd2,3'b100});
    check("dirty match write 1.2",0,0, '0, '0, 1, 32'habad, 0);
    dcif.dmemWEN = 0;
    @(posedge CLK);
    check("dirty match write 1.3",0,0, '0, '0, 0, 32'hbcde, 0);

    dcif.dmemWEN = 1;
    dcif.dmemaddr = word_t'({tag1,3'd3,3'b100});
    dcif.dmemstore = 32'hbcde;
    @(posedge CLK);
    @(posedge CLK);
    dcif.dmemaddr = word_t'({tag1,3'd3,3'b000});
    check("dirty match write 2.1",0,0, '0, '0, 1, 32'h3, 0);
    dcif.dmemaddr = word_t'({tag1,3'd3,3'b100});
    check("dirty match write 2.2",0,0, '0, '0, 1, 32'hbcde, 0);
    dcif.dmemWEN = 0;
    @(posedge CLK);
    check("dirty match write 2.3",0,0, '0, '0, 0, 32'hbcde, 0);


//back to ideal state
    @(posedge CLK);
    //tag not match but dirty
    dcif.dmemREN = 1;
    dwait = 1;
    //make the entry 1 become the MRU
    dcif.dmemaddr = word_t'({tag1,3'd4,3'b0});
    @(posedge CLK);
    @(posedge CLK);
    //back to ideal
    test_tag = "ideal";
    dcif.dmemaddr = word_t'({tag3,3'd4,3'b0});
    @(posedge CLK);
    test_tag = "flush";
    check("dirty not match read 1.1",0,1, {tag2,3'd4,3'b000}, 32'hcccc+4, 0, '0, 0);
    //mem latency
    @(posedge CLK);
    check("dirty not match read 1.1",0,1, {tag2,3'd4,3'b000}, 32'hcccc+4, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match read 1.1",0,1, {tag2,3'd4,3'b000}, 32'hcccc+4, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match read 1.1",0,1, {tag2,3'd4,3'b000}, 32'hcccc+4, 0, '0, 0);
    dwait = 0;
    @(posedge CLK);
    check("dirty not match read 1.2",0,1,{tag2,3'd4,3'b100}, 32'h4, 0, '0, 0);
    dwait = 1;
    //mem latency
    @(posedge CLK);
    check("dirty not match read 1.2",0,1,{tag2,3'd4,3'b100}, 32'h4, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match read 1.2",0,1,{tag2,3'd4,3'b100}, 32'h4, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match read 1.2",0,1,{tag2,3'd4,3'b100}, 32'h4, 0, '0, 0);
    dwait = 0;
    @(posedge CLK);
    //@(posedge CLK);
    dwait = 1;
    test_tag = "load";

    check("dirty not match read 1.3",1,0, word_t'({tag3,3'd4,3'b0}), '0, 0, '0, 0);
    //mock mem latency
    @(posedge CLK);
    check("dirty not match read 1.3",1,0, word_t'({tag3,3'd4,3'b0}), '0, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match read 1.3",1,0, word_t'({tag3,3'd4,3'b0}), '0, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match read 1.3",1,0, word_t'({tag3,3'd4,3'b0}), '0, 0, '0, 0);
    dwait = 0;
    dload = 32'h1234;
    @(posedge CLK);
    dwait = 1;
    check("dirty not match read 1.3.1",1,0, word_t'({tag3,3'd4,3'd4}), '0, 0, '0, 0);

    @(posedge CLK);
    check("dirty not match read 1.3.1",1,0, word_t'({tag3,3'd4,3'd4}), '0, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match read 1.3.1",1,0, word_t'({tag3,3'd4,3'd4}), '0, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match read 1.3.1",1,0, word_t'({tag3,3'd4,3'd4}), '0, 0, '0, 0);
    dwait = 0;
    dload = 32'h7890;
    @(posedge CLK);
    //@(posedge CLK);

    check("dirty not match read 1.4",0,0, '0, '0, 1, 32'h1234, 0);
    dcif.dmemaddr = word_t'({tag3,3'd4,3'b100});
    check("dirty not match read 1.5",0,0, '0, '0, 1, 32'h7890, 0);
    dcif.dmemREN = 0;
    dwait = 1;
    @(posedge CLK);
    test_tag = "ideal distinguish next test";
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);

    //write to dirty
    test_tag = "ideal wirte dirty not matchtest";

    dcif.dmemREN = 1;
    dwait = 1;
    //make the entry 1 become the MRU
    dcif.dmemaddr = word_t'({tag1,3'd5,3'b0});
    @(posedge CLK);
    @(posedge CLK);
    dcif.dmemREN = 0;
    dcif.dmemWEN = 1;
    //back to ideal
    test_tag = "ideal";
    dcif.dmemaddr = word_t'({tag3,3'd5,3'b0});
    @(posedge CLK);
    test_tag = "flush";
    check("dirty not match write 1.1",0,1, {tag2,3'd5,3'b000}, 32'hcccc+5, 0, '0, 0);
    //mem latency
    @(posedge CLK);
    check("dirty not match write 1.1",0,1, {tag2,3'd5,3'b000}, 32'hcccc+5, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match write 1.1",0,1, {tag2,3'd5,3'b000}, 32'hcccc+5, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match write 1.1",0,1, {tag2,3'd5,3'b000}, 32'hcccc+5, 0, '0, 0);
    dwait = 0;
    @(posedge CLK);
    check("dirty not match write 1.2",0,1,{tag2,3'd5,3'b100}, 32'h5, 0, '0, 0);
    dwait = 1;
    //mem latency
    @(posedge CLK);
    check("dirty not match write 1.2",0,1,{tag2,3'd5,3'b100}, 32'h5, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match write 1.2",0,1,{tag2,3'd5,3'b100}, 32'h5, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match write 1.2",0,1,{tag2,3'd5,3'b100}, 32'h5, 0, '0, 0);
    dwait = 0;
    @(posedge CLK);
    //@(posedge CLK);
    dwait = 1;
    test_tag = "load";

    check("dirty not match write 1.3",1,0, word_t'({tag3,3'd5,3'b0}), '0, 0, '0, 0);
    //mock mem latency
    @(posedge CLK);
    check("dirty not match write 1.3",1,0, word_t'({tag3,3'd5,3'b0}), '0, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match write 1.3",1,0, word_t'({tag3,3'd5,3'b0}), '0, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match write 1.3",1,0, word_t'({tag3,3'd5,3'b0}), '0, 0, '0, 0);
    dwait = 0;
    dload = 32'h1111;
    @(posedge CLK);
    dwait = 1;
    check("dirty not match write 1.3.1",1,0, word_t'({tag3,3'd5,3'd4}), '0, 0, '0, 0);

    @(posedge CLK);
    check("dirty not match write 1.3.1",1,0, word_t'({tag3,3'd5,3'd4}), '0, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match write 1.3.1",1,0, word_t'({tag3,3'd5,3'd4}), '0, 0, '0, 0);
    @(posedge CLK);
    check("dirty not match write 1.3.1",1,0, word_t'({tag3,3'd5,3'd4}), '0, 0, '0, 0);
    dwait = 0;
    dload = 32'h4444;
    @(posedge CLK);
    test_tag = "write from load";

    dcif.dmemstore = 32'h5555;
    @(posedge CLK);
    test_tag = "LW";
    check("dirty not match write LW1",0,0, '0, '0, 1, 32'h5555, 0);
    dcif.dmemaddr = word_t'({tag3,3'd5,3'b100});
    check("dirty not match write LW2",0,0, '0, '0, 1, 32'h4444, 0);
    @(posedge CLK);
    dcif.dmemWEN = 0;
    test_tag = "back to ideal";
    check("dirty not match write ideal1",0,0, '0, '0, 0, 32'h4444, 0);
    dcif.dmemaddr = word_t'({tag3,3'd5,3'b000});
    check("dirty not match write ideal2",0,0, '0, '0, 0, 32'h5555, 0);
    @(posedge CLK);

    ///////////////////////////////////////////////////////////////////////
    // final flush test
    RESET();
    test_tag = "back to ideal";
    for (int i = 0; i < 8; i++)
    begin
        // the other half
        ind = i;
        dcif.dmemWEN = 1;
        //dmemStore = 32'h00aa + i;
        dcif.dmemaddr = word_t'({tag1,ind,3'b0});
        dcif.dmemstore = 32'b0 + i;
        dwait = 1;
        @(posedge CLK);
        //mock load/////////////////
        test_tag = "load";
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        dwait = 0;
        dload = 32'h578d;
        @(posedge CLK);
        dwait = 1;

        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        dwait = 0;
        dload = 32'h578c;
        @(posedge CLK);
        dwait = 1;
        ////////////////////////////

        test_tag = "write";
        check("write before flush write1",0,0, '0, '0, 0, 32'h578d, 0);
        check("write before flush write2",0,0, '0, '0, 0, 32'h578c, 0);
        dcif.dmemWEN = 0;
        @(posedge CLK);
        test_tag = "LW";
        dcif.dmemaddr = word_t'({tag1,ind,3'b000});
        check("write before flush ideal1",0,0, '0, '0, 1, 32'h0+i, 0);
        dcif.dmemaddr = word_t'({tag1,ind,3'b100});
        check("write before flush ideal2",0,0, '0, '0, 1, 32'h578c, 0);
        dcif.dmemWEN = 0;
        @(posedge CLK);
        test_tag = "back to ideal again hahaha";
    end

    //start flushing
    dcif.halt = 1;
    @(posedge CLK);

    test_tag = "flush1";
    for(int i = 0; i < 16; i ++)
    begin
        check("flush 1" + i,0,0, '0, '0, 0, '0, 0);
        @(posedge CLK);
        //@(posedge CLK);
        dwait = 1;
    end

    test_tag = "start flush valid frame";
    for(int i = 0; i < 8; i ++)
    begin
        ind = i;
        check("flush 2.1",0,1, {tag1,ind,3'b100}, 32'h578c, 0, '0, 0);
        //mem latency
        @(posedge CLK);
        check("flush 2.2",0,1, {tag1,ind,3'b100}, 32'h578c, 0, '0, 0);
        @(posedge CLK);
        check("flush 2.3",0,1, {tag1,ind,3'b100}, 32'h578c, 0, '0, 0);
        @(posedge CLK);
        check("flush 2.4",0,1, {tag1,ind,3'b100}, 32'h578c, 0, '0, 0);
        dwait = 0;
        @(posedge CLK);
        dwait = 1;
    end
    for(int i = 0; i < 7; i ++)
    begin
        ind = i;
        check("flush 3.1",0,1,{tag1,ind,3'b000}, 32'h0+i, 0, '0, 0);
        dwait = 1;
        //mem latency
        @(posedge CLK);
        check("flush 3.2",0,1,{tag1,ind,3'b000}, 32'h0+i, 0, '0, 0);
        @(posedge CLK);
        check("flush 3.3",0,1,{tag1,ind,3'b000}, 32'h0+i, 0, '0, 0);
        @(posedge CLK);
        check("flush 3.4",0,1,{tag1,ind,3'b000}, 32'h0+i, 0, '0, 0);
        dwait = 0;
        @(posedge CLK);
        //@(posedge CLK);
        dwait = 1;
    end
    check("flush 3.1",0,1,{tag1,3'h7,3'b000}, 32'h7, 0, '0, 0);
    dwait = 1;
    //mem latency
    @(posedge CLK);
    check("flush 3.2",0,1,{tag1,3'h7,3'b000}, 32'h7, 0, '0, 0);
    @(posedge CLK);
    check("flush 3.3",0,1,{tag1,3'h7,3'b000}, 32'h7, 0, '0, 0);
    @(posedge CLK);
    check("flush 3.4",0,1,{tag1,3'h7,3'b000}, 32'h7, 0, '0, 0);
    dwait = 0;

    @(posedge CLK);
    dwait = 1;

    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);
    dwait = 0;
    @(posedge CLK);
    // test flush signal
    check("test flush signal",0,1,{tag1,3'd7,3'b000}, 32'd7, 0, '0, 1);
    $finish;
end
endprogram
