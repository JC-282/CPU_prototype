// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: source
// description: source file for decode stage

`include "stage_id_if.vh"
`include "register_file_if.vh"
`include "control_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module stage_id
(
    input logic CLK,nRST,
    stage_id_if.id idif
);

    //interfae
    register_file_if rfif();
    control_unit_if cuif();

    //internal signal
    word_t wdat;
    word_t imme;

    //function call
    register_file rfid (CLK,nRST,rfif);
    control_unit cuid (cuif);

    assign idif.npc_out = idif.npc_in;
    assign idif.imemload_out = idif.imemload_in;

    //control unit
    assign idif.halt_out     = cuif.halt;
    assign idif.regWrite_out = cuif.regWrite;
    assign idif.regDst_out   = cuif.regDst;
    assign idif.branch_out   = cuif.branch;
    assign idif.aluOp_out   = cuif.aluOp;
    assign idif.alusrc_out   = cuif.aluSrc;
    assign idif.memWrite_out = cuif.memWrite;
    assign idif.memRead_out  = cuif.memRead;
    assign idif.memtoReg_out = cuif.memtoReg;
    assign idif.jal_out      = cuif.jal;
    assign idif.jump_out     = cuif.jump;
    assign cuif.op           = opcode_t'(idif.imemload_out[31:26]);
    assign cuif.funcop       = funct_t'(idif.imemload_out[5:0]);
    //reg file
    assign rfif.rsel1 = idif.imemload_in[25:21];
    assign rfif.rsel2 = idif.imemload_in[20:16];
    assign rfif.wsel  = idif.regSelWB_in;
    assign rfif.WEN   = idif.regWriteWB_in;
    assign idif.rdat1_out = rfif.rdat1;
    assign idif.rdat2_out = rfif.rdat2;
    //atomicity
    assign idif.datomic_out = cuif.datomic;
   // assign rfif.wdat  = wdat;
    always_comb
    begin
        if(idif.jalWB_in)
        begin
            rfif.wdat = idif.npcWB_in;
        end
        else
        begin
            rfif.wdat = idif.wdatWB_in;
        end
    end

    //extender
    assign idif.imme_out = imme;
    always_comb
    begin
        case(cuif.extender)
            0: imme = {16'b0, idif.imemload_in[15:0]};
            1: imme = {{16{idif.imemload_in[15]}},idif.imemload_in[15:0]};
            2: imme = {idif.imemload_in[15:0], 16'b0};
            default : imme = {16'b0, idif.imemload_in[15:0]};
        endcase
    end
endmodule
