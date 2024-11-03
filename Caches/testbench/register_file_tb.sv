/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();
  // test program
  test PROG (CLK, v1, v2, v3, nRST, rfif);
  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif

endmodule

program test
(
    input logic CLK,
    input int v1, v2, v3,
    output logic nRST,
    register_file_if.tb rfif
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

    // check value task

    initial
    begin
//************************Verify writes and reads to registers*******************//
        // v1
        RESET();
        rfif.WEN    = 1;
        rfif.wsel   = 0;
        rfif.rsel1  = 0;
        rfif.rsel2  = 0;
        rfif.wdat   = v1;
        @(posedge CLK);
        for (int i = 0; i < 32; i++)
        begin
            rfif.wsel = i;
            @(posedge CLK);
        end

        for (int i = 0; i < 32; i++)
        begin
            rfif.rsel1 = i;
            rfif.rsel2 = i;
            @(posedge CLK);
            if (i == 0)
            begin
                if (rfif.rdat1 != 0)
                begin
                    $display("w/r TESTv1: case: %d, data1 = %d, expected 0", i, rfif.rdat1);
                end
                if (rfif.rdat2 != 0)
                begin
                    $display("w/r TESTv1: case: %d, data2 = %d, expected 0", i, rfif.rdat2);
                end
            end
            else
            begin
                if (rfif.rdat1 != v1)
                begin
                    $display("w/r TESTv1: case: %d, data1 = %d, expected %d", i, rfif.rdat1, v1);
                end
                if (rfif.rdat2 != v1)
                begin
                    $display("w/r TESTv1: case: %d, data2 = %d, expected %d", i, rfif.rdat2, v1);
                end
            end
        end


        // v2
        RESET();
        rfif.WEN    = 1;
        rfif.wsel   = 0;
        rfif.rsel1  = 0;
        rfif.rsel2  = 0;
        rfif.wdat   = v2;
        @(posedge CLK);
        for (int i = 0; i < 32; i++)
        begin
            rfif.wsel = i;
            @(posedge CLK);
        end

        for (int i = 0; i < 32; i++)
        begin
            rfif.rsel1 = i;
            rfif.rsel2 = i;
            @(posedge CLK);
            if (i == 0)
            begin
                if (rfif.rdat1 != 0)
                begin
                    $display("w/r TESTv2: case: %d, data1 = %d, expected 0", i, rfif.rdat1);
                end
                if (rfif.rdat2 != 0)
                begin
                    $display("w/r TESTv2: case: %d, data2 = %d, expected 0", i, rfif.rdat2);
                end
            end
            else
            begin
                if (rfif.rdat1 != v2)
                begin
                    $display("w/r TESTv2: case: %d, data1 = %d, expected %d", i, rfif.rdat1, v2);
                end
                if (rfif.rdat2 != v2)
                begin
                    $display("w/r TESTv2: case: %d, data2 = %d, expected %d", i, rfif.rdat2, v2);
                end
            end
        end

        // v3
        RESET();
        rfif.WEN    = 1;
        rfif.wsel   = 0;
        rfif.rsel1  = 0;
        rfif.rsel2  = 0;
        rfif.wdat   = v3;
        @(posedge CLK);
        for (int i = 0; i < 32; i++)
        begin
            rfif.wsel = i;
            @(posedge CLK);
        end

        for (int i = 0; i < 32; i++)
        begin
            rfif.rsel1 = i;
            rfif.rsel2 = i;
            @(posedge CLK);
            if (i == 0)
            begin
                if (rfif.rdat1 != 0)
                begin
                    $display("w/r TESTv3: case: %d, data1 = %d, expected 0", i, rfif.rdat1);
                end
                if (rfif.rdat2 != 0)
                begin
                    $display("w/r TESTv3: case: %d, data2 = %d, expected 0", i, rfif.rdat2);
                end
            end
            else
            begin
                if (rfif.rdat1 != v3)
                begin
                    $display("w/r TESTv3: case: %d, data1 = %d, expected %d", i, rfif.rdat1, v3);
                end
                if (rfif.rdat2 != v3)
                begin
                    $display("w/r TESTv3: case: %d, data2 = %d, expected %d", i, rfif.rdat2, v3);
                end
            end
        end

//**************************Test writes to register 0*******************//
    // Test writes to register 0: 1
        RESET();
        rfif.WEN    = 1;
        rfif.wsel   = 0;
        rfif.rsel1  = 0;
        rfif.rsel2  = 0;
        rfif.wdat   = v1;
        @(posedge CLK);
        if (rfif.rdat1 != 0)
        begin
            $display("WRITE TO REGISTER0 TEST: case: 1, data1 = %d, expected 0", rfif.rdat1);
        end
        if (rfif.rdat2 != 0)
        begin
            $display("WRITE TO REGISTER0 TEST: case: 1, data2 = %d, expected 0", rfif.rdat2);
        end

    // Test writes to register 0: 2
        RESET();
        rfif.WEN    = 1;
        rfif.wsel   = 0;
        rfif.rsel1  = 0;
        rfif.rsel2  = 0;
        rfif.wdat   = v2;
        @(posedge CLK);
        if (rfif.rdat1 != 0)
        begin
            $display("WRITE TO REGISTER0 TEST: case: 2, data1 = %d, expected 0", rfif.rdat1);
        end
        if (rfif.rdat2 != 0)
        begin
            $display("WRITE TO REGISTER0 TEST: case: 2, data2 = %d, expected 0", rfif.rdat2);
        end

    // Test writes to register 0: 3
        RESET();
        rfif.WEN    = 1;
        rfif.wsel   = 0;
        rfif.rsel1  = 0;
        rfif.rsel2  = 0;
        rfif.wdat   = v3;
        @(posedge CLK);
        if (rfif.rdat1 != 0)
        begin
            $display("WRITE TO REGISTER0 TEST: case: 3, data1 = %d, expected 0", rfif.rdat1);
        end
        if (rfif.rdat2 != 0)
        begin
            $display("WRITE TO REGISTER0 TEST: case: 3, data2 = %d, expected 0", rfif.rdat2);
        end

//***********************Test asynchronous reset of register*******************//
    // RESET test verification
        RESET();
        for (int i = 0; i < 32; i++)
        begin
            rfif.rsel1 = i;
            rfif.rsel2 = i;
            @(posedge CLK);
            if (rfif.rdat1 != 0)
            begin
                $display("RESET TEST: case: %d, data1 = %d, expected 0", i, rfif.rdat1);
            end
            if (rfif.rdat2 != 0)
            begin
                $display("RESET TEST: case: %d, data2 = %d, expected 0", i, rfif.rdat2);
            end
        end

//***********************WEN is pull low********************************//
        RESET();
        rfif.WEN    = 0;
        rfif.wsel   = 0;
        rfif.rsel1  = 0;
        rfif.rsel2  = 0;
        rfif.wdat   = v3;
        @(posedge CLK);
        for (int i = 0; i < 32; i++)
        begin
            rfif.wsel = i;
            @(posedge CLK);
        end

        for (int i = 0; i < 32; i++)
        begin
            rfif.rsel1 = i;
            rfif.rsel2 = i;
            @(posedge CLK);
            if (rfif.rdat1 != 0)
            begin
                $display("WEN pull low: case: %d, data1 = %d, expected 0", i, rfif.rdat1);
            end
            if (rfif.rdat2 != 0)
            begin
                $display("WEN pull low: case: %d, data2 = %d, expected 0", i, rfif.rdat2);
            end
        end
    $display("End of TEST.");
    $finish;
    end
endprogram
