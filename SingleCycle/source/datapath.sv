/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"

`include "control_unit_if.vh"
`include "register_file_if.vh"
`include "alu_if.vh"
`include "request_unit_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath (
    input logic CLK, nRST,
    datapath_cache_if.dp dpif
);
    // import types
    import cpu_types_pkg::*;

    // pc init
    parameter PC_INIT = 0;

    word_t imme, npc, wdat;
    logic im_halt; // medium value for halt
    word_t prev_d, ndmem, fordmem;
    word_t imeml;

    // call the interface
    control_unit_if cuif();
    register_file_if rfif();
    alu_if aluif();
    request_unit_if ruif();

    // finish control unit connection with outside
    assign cuif.op = opcode_t'(dpif.imemload[31:26]);
    assign cuif.funcop = funct_t'(dpif.imemload[5:0]);
    assign fordmem = (dpif.dhit) ? dpif.dmemload : prev_d;
    //assign imeml = (ihit) ? dpif.imemload : 0;

    // call the module
    alu al (CLK, aluif);
    control_unit conu (cuif);
    assign im_halt = cuif.halt;

    request_unit requ (CLK, nRST, ruif);
    register_file regf (CLK, nRST,
                        rfif);

    program_counter pc (CLK, nRST,
                        dpif.ihit, aluif.zero,
                        imme, rfif.rdat1,
                        dpif.imemload[25:0],
                        dpif.imemaddr, npc,
                        cuif);

    assign wdat = cuif.memtoReg ? fordmem : aluif.outport;
    assign dpif.dmemstore = rfif.rdat2;
    assign dpif.dmemaddr = aluif.outport;

    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            dpif.halt <= 0;
            prev_d <= 0;
        end
        else
        begin
            dpif.halt <= dpif.halt | im_halt;
            prev_d <= ndmem;
        end
    end

    always_comb
    begin
        ndmem = prev_d;
        if (dpif.dhit)
        begin
            ndmem = dpif.dmemload;
        end

        // extender block code
        imme = 0;
        case (cuif.extender)
            0:  imme = {16'b0, dpif.imemload[15:0]};
            1:  imme = { { 16{dpif.imemload[15]} },  dpif.imemload[15:0] };
            2:  imme = {dpif.imemload[15:0], 16'b0};
        endcase

        // aluif interface input
        aluif.porta = rfif.rdat1;
        aluif.portb =  (cuif.aluSrc) ? imme : rfif.rdat2;
        aluif.aluop = cuif.aluOp;

        // register file interface input
        rfif.WEN = cuif.regWrite && (dpif.ihit || dpif.dhit);
        rfif.wsel = dpif.imemload[15:11];
        if (cuif.regDst == 0)
        begin
            rfif.wsel = dpif.imemload[15:11];
        end
        else if (cuif.regDst == 1)
        begin
            rfif.wsel = dpif.imemload[20:16];
        end
        else if (cuif.regDst == 2)
        begin
            rfif.wsel = 31;
        end
        rfif.rsel1 = dpif.imemload[25:21];
        rfif.rsel2 = dpif.imemload[20:16];
        rfif.wdat = cuif.jal ? npc : wdat;


        // connect intrface request unit
        ruif.memRead = cuif.memRead;
        ruif.memWrite = cuif.memWrite;
        ruif.ihit = dpif.ihit;
        ruif.dhit = dpif.dhit;
        ruif.halt = dpif.halt;
        dpif.dmemWEN = ruif.dmemWen;
        dpif.dmemREN = ruif.dmemRen;
        dpif.imemREN = ruif.imemRen;

    end


endmodule
