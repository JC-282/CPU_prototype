// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: source file
// description: source file for stage execution
`include "stage_exe_if.vh"
`include "alu_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;


module stage_exe
(
    input logic CLK, nRST,
    stage_exe_if.ex exif,
    for_unit_if.ex fuif
);

    alu_if aluif();
    logic zero;
    word_t s_baddr; // shift address for branch mux

    logic [27:0] s_jaddr; // shift address for jump mux

    alu al (aluif);
    // assign block for MEM nad WB
    assign exif.jump_out = exif.jump_in;
    assign exif.memtoReg_out = exif.memtoReg_in;
    assign exif.jal_out = exif.jal_in;
    assign exif.regWrite_out = exif.regWrite_in;
    assign exif.npc_out = exif.npc_in;
    assign exif.halt_out = exif.halt_in;
    assign exif.memRead_out = exif.memRead_in;
    assign exif.memWrite_out = exif.memWrite_in;
    assign exif.datomic_out = exif.datomic_in;

    assign s_jaddr = exif.imemload_in[25:0] << 2;
    assign exif.jumpaddr_out = {exif.npc_in[31:28], s_jaddr};
    assign exif.branchSel_out = (exif.branch_in == 1 && zero == 1 ||
                        exif.branch_in == 2 && zero == 0) ? 1 : 0;


    assign s_baddr = exif.imme_in << 2;
    assign exif.branchaddr_out = s_baddr + exif.npc_in;

    assign aluif.porta = exif.rdat1_out;
    assign aluif.portb =  (exif.ALUsrc_in) ? exif.imme_in : exif.rdat2_out;

    always_comb
    begin


        // connect alu unit
        aluif.aluop = exif.aluOp_in;
        exif.aluOut_out = aluif.outport;
        zero = aluif.zero;

        exif.regSel_out = exif.imemload_in[15:11];
        if (exif.regDst_in == 0)
        begin
            exif.regSel_out = exif.imemload_in[15:11];
        end
        else if (exif.regDst_in == 1)
        begin
            exif.regSel_out = exif.imemload_in[20:16];
        end
        else if (exif.regDst_in == 2)
        begin
            exif.regSel_out = 31;
        end

        //forwarding logic
        exif.rdat1_out = exif.rdat1_in;
        exif.rdat2_out = exif.rdat2_in;
        //portA
        if(fuif.portaSel == 1)
        begin
            exif.rdat1_out = exif.for_dat1_mem_in;
        end
        if(fuif.portaSel == 2)
        begin
            exif.rdat1_out = exif.for_dat1_wb_in;
        end
        //portB
        if(fuif.portbSel == 1)
        begin
            exif.rdat2_out = exif.for_dat2_mem_in;
        end
        if(fuif.portbSel == 2)
        begin
            exif.rdat2_out = exif.for_dat2_wb_in;
        end

    end

endmodule

