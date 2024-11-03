// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: sv source file
// description: this is the source file for control unit


`include "control_unit_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module control_unit
(
    control_unit_if.cu cuif
);

    //assign cuif.aluSrc = (cuif.op == RTYPE || cuif.op == BEQ || cuif.op == BNE) ? 0 : 1;
    //assign cuif.jal = (cuif.op == JAL) ? 1 : 0;
    //assign cuif.memRead = (cuif.op == LW) ? 1 : 0;
    //assign cuif.memtoReg = (cuif.op == LW) ? 1 : 0;
    //assign cuif.memWrite = (cuif.op == SW) ? 1 : 0;

    //assign cuif.regWrite = (cuif.op == BEQ ||
      //                      cuif.op == BNE ||
        //                    cuif.op == SW ||
          //                  (cuif.op == RTYPE && cuif.funcop == JR) ) ? 0 : 1;

    //assign cuif.halt = (cuif.op == HALT) ? 1 : 0;
    always_comb
    begin
        cuif.jump       = 0; // default for not jump
        cuif.branch     = 0; // default for not branch
        cuif.regDst     = 0; // default for rtype
        cuif.extender   = 1; // default for sign extend
        cuif.aluOp      = aluop_t'('0);
        cuif.halt       = 0;
        cuif.aluSrc     = 1;
        cuif.jal        = 0;
        cuif.memRead    = 0;
        cuif.memtoReg   = 0;
        cuif.memWrite   = 0;
        cuif.regWrite   = 1;
        cuif.datomic    = 0;

        //datomic
        if(cuif.op == SC || cuif.op == LL)
        begin
            cuif.datomic = 1;
        end

        //memtoReg for SC
        if(cuif.op == SC)
        begin
            cuif.memtoReg = 1;
        end

        // aluSrc
        if (cuif.op == RTYPE || cuif.op == BEQ || cuif.op == BNE)
        begin
            cuif.aluSrc = 0;
        end

        // jal
        if (cuif.op == JAL)
        begin
            cuif.jal = 1;
        end

        // memRead and memtoReg
        if (cuif.op == LW || cuif.op == LL)
        begin
            cuif.memRead = 1;
            cuif.memtoReg = 1;
        end

        // memWrite
        if (cuif.op == SW || cuif.op == SC)
        begin
            cuif.memWrite = 1;
        end

        // regWrite
        if (cuif.op == BEQ || cuif.op == BNE || cuif.op == SW ||
            (cuif.op == RTYPE && cuif.funcop == JR)
            || (cuif.op == RTYPE && cuif.funcop == funct_t'(0))
            )
        begin
            cuif.regWrite = 0;
        end

        // halt signal
        if (cuif.op == HALT)
        begin
            cuif.halt = 1;
        end

        // if statement for jump signal
        if (cuif.op == J || cuif.op == JAL)
        begin
            cuif.jump = 1;
        end
        else if (cuif.op == RTYPE && cuif.funcop == JR)
        begin
            cuif.jump = 2;
        end

        // if statement for branch signal
        if (cuif.op == BEQ)
        begin
            cuif.branch = 1;
        end
        else if (cuif.op == BNE)
        begin
            cuif.branch = 2;
        end

        // if statment for regDst signal
        if (cuif.op == JAL)
        begin
            cuif.regDst = 2;
        end
        else if (cuif.op != RTYPE && cuif.op != JAL)
        begin
            cuif.regDst = 1;
        end

        // if statement for extender signal
        if (cuif.op == ANDI ||
            cuif.op == ORI ||
            cuif.op == XORI)
        begin
            cuif.extender = 0;
        end
        else if (cuif.op == LUI)
        begin
            cuif.extender = 2;
        end

        // terrible codes for aluOp signal
        if(cuif.op != RTYPE)
        begin
            case(cuif.op)
                ADDIU:  cuif.aluOp = ALU_ADD;
                ADDI:   cuif.aluOp = ALU_ADD;
                ANDI:   cuif.aluOp = ALU_AND;
                BEQ:    cuif.aluOp = ALU_SUB;
                BNE:    cuif.aluOp = ALU_SUB;
                LUI,
                LW:     cuif.aluOp = ALU_ADD;
                ORI:    cuif.aluOp = ALU_OR;
                SLTI:   cuif.aluOp = ALU_SLT;
                SLTIU:  cuif.aluOp = ALU_SLTU;
                SW:     cuif.aluOp = ALU_ADD;
                LL:     cuif.aluOp = ALU_ADD;
                SC:     cuif.aluOp = ALU_ADD;
                XORI:   cuif.aluOp = ALU_XOR;
            endcase
        end
        else
        begin
            case(cuif.funcop)
                ADDU:   cuif.aluOp = ALU_ADD;
                ADD:    cuif.aluOp = ALU_ADD;
                AND:    cuif.aluOp = ALU_AND;
                JR,
                NOR:    cuif.aluOp = ALU_NOR;
                OR:     cuif.aluOp = ALU_OR;
                SLT:    cuif.aluOp = ALU_SLT;
                SLTU:   cuif.aluOp = ALU_SLTU;
                SLLV:   cuif.aluOp = ALU_SLL;
                SRLV:   cuif.aluOp = ALU_SRL;
                SUBU:   cuif.aluOp = ALU_SUB;
                SUB:    cuif.aluOp = ALU_SUB;
                XOR:    cuif.aluOp = ALU_XOR;
            endcase
        end

    end
endmodule
