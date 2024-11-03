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
`include "stage_if_if.vh"
`include "stage_id_if.vh"
`include "stage_exe_if.vh"
`include "stage_mem_if.vh"
`include "stage_wb_if.vh"

`include "haz_det_if.vh"
`include "for_unit_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath
#(
    // pc init
    parameter PC_INIT = 0
)
(
    input logic CLK, nRST,
    datapath_cache_if.dp dpif
);
    // import types
    import cpu_types_pkg::*;



    //interface
    stage_if_if ifif();
    stage_id_if idif();
    stage_exe_if exif();
    stage_mem_if memif();
    stage_wb_if wbif();
    haz_det_if hdif();
    for_unit_if fuif();

    // module call
    stage_if sif (PC_INIT, CLK, nRST, ifif, hdif);
    stage_id sid (CLK, nRST, idif);
    stage_exe sexe (CLK, nRST, exif, fuif);
    stage_mem smem (CLK, nRST, memif);
    stage_wb swb (CLK, nRST, wbif);
    haz_det haz (CLK, nRST, hdif);
    for_unit fu (CLK, nRST, fuif);




    // signal to move the latch or update the PC counter
    logic move;
    assign move = (dpif.dmemREN | dpif.dmemWEN) ? (dpif.ihit && dpif.dhit) : dpif.ihit;

    // assign all necessary signals to datapath interface
    assign dpif.halt            = memif.halt_out;
    assign dpif.imemREN         = ~memif.halt_out;
    assign dpif.dmemWEN         = memif.memWrite_out;
    assign dpif.dmemREN         = memif.memRead_out;
    assign dpif.dmemaddr        = memif.dmemaddr_out;
    assign dpif.dmemstore       = memif.dmemstore_out;
    assign dpif.imemaddr        = ifif.imemaddr_out;
    assign dpif.datomic         = memif.datomic_out;

    ///*************************************************************
    // to latch the previous data when memory is not access
    word_t prev_d, next_d;
    assign memif.dmemload_in = (dpif.dhit) ? dpif.dmemload : prev_d;
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)  prev_d <= 0;
        else        prev_d <= next_d;
    end

    always_comb
    begin
        // to latch the dmemload
        next_d = prev_d;
        if (dpif.dhit)
        begin
            next_d = dpif.dmemload;
        end
    end
    //***********************************************************




    //************************************************************
    ////////////connect all the no latch input output signal in datapath
    assign ifif.imemload_in     = dpif.imemload;

    //MEM to IF for branch jump.....
    assign ifif.jump_in         = memif.jump_out;
    assign ifif.branchSel_in    = memif.branchSel_out;
    assign ifif.jumpaddr_in     = memif.jumpaddr_out;
    assign ifif.branchaddr_in   = memif.branchaddr_out;
    assign ifif.rdata1_in       = memif.rdat1_out;
    assign ifif.ihit            = move;

    //WB to ID
    assign idif.wdatWB_in       = wbif.wdat_out;
    assign idif.npcWB_in        = wbif.npc_out;
    assign idif.regWriteWB_in   = wbif.regWrite_out;
    assign idif.jalWB_in        = wbif.jal_out;
    assign idif.regSelWB_in     = wbif.regSel_out;

    //MEM to EX
    assign exif.for_dat1_mem_in = memif.aluOut_in;
    assign exif.for_dat2_mem_in = memif.aluOut_in;

    //WB to EX
    assign exif.for_dat1_wb_in = wbif.wdat_out;
    assign exif.for_dat2_wb_in = wbif.wdat_out;


    //************************************************************




    //************************************************************
    //to hazard detection unit
    assign hdif.branchSel = memif.branchSel_out;
    assign hdif.jump = memif.jump_out;
    assign hdif.memRead_ex = exif.memRead_out;
    assign hdif.rt_ex = exif.imemload_in[20:16];
    assign hdif.imemload_id = idif.imemload_out;
    assign hdif.memtoReg_ex = exif.memtoReg_out;
    assign hdif.datomic_ex = exif.datomic_out;
    //************************************************************





    //************************************************************
    // connect for forward unit
    assign fuif.regSel_mem = memif.regSel_out;
    assign fuif.regSel_wb = wbif.regSel_out;
    assign fuif.regWrite_mem = memif.regWrite_out;
    assign fuif.regWrite_wb = wbif.regWrite_out;
    assign fuif.rs_ex = exif.imemload_in[25:21];
    assign fuif.rt_ex = exif.imemload_in[20:16];

    //************************************************************


//**********************below is pipeline latch section**********//////
    ////////////////variable into IF/ID latch/////////////////
    word_t      id_npc_in;
    word_t      id_imemload_in;


    ////////////////variable into ID/EXE latch/////////////////
    word_t      exe_npc_in;
    word_t      exe_imemload_in;
    logic       exe_regWrite_in;
    logic [1:0] exe_regDst_in;
    logic [1:0] exe_branch_in;
    logic       exe_ALUsrc_in;
    logic       exe_memtoReg_in;
    logic       exe_jal_in;
    logic [1:0] exe_jump_in;
    word_t      exe_rdat1_in;
    word_t      exe_rdat2_in;
    word_t      exe_imme_in;
    logic       exe_halt_in;
    logic       exe_memRead_in;
    logic       exe_memWrite_in;
    aluop_t     exe_aluOp_in;
    logic       exe_datomic_in;


    ////////////////variable into EXE/MEM latch/////////////////
    word_t      mem_jumpaddr_in;
    logic [1:0] mem_jump_in;
    logic       mem_branchSel_in;
    word_t      mem_branchaddr_in;
    word_t      mem_npc_in;
    logic       mem_memtoReg_in;
    logic       mem_jal_in;
    logic       mem_regWrite_in;
    word_t      mem_aluOut_in;
    word_t      mem_rdat1_in;
    word_t      mem_dmemstore_in;
    logic [4:0] mem_regSel_in;
    logic       mem_halt_in;
    logic       mem_memRead_in;
    logic       mem_memWrite_in;
    logic       mem_datomic_in;
    word_t      imemload_test, n_imemload_test;

    ////////////////variable into MEM/WB latch/////////////////
    word_t      wb_npc_in;
    logic       wb_memtoReg_in;
    word_t      wb_dmemload_in;
    word_t      wb_aluOut_in;
    logic [4:0] wb_regSel_in;
    logic       wb_jal_in;
    logic       wb_regWrite_in;


    /////////////latch release signal/////////////////////////
    logic if_id_en;
    logic id_ex_en;
    logic ex_mem_en;
    logic mem_wb_en;
    assign if_id_en = move && ~hdif.stall;
    assign id_ex_en = move;
    assign ex_mem_en = move;
    assign mem_wb_en = move;



    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            // latch IF-ID
            idif.npc_in             <= 0;
            idif.imemload_in        <= 0;

            // latch ID-EXE
            exif.npc_in             <= 0;
            exif.imemload_in        <= 0;
            exif.regWrite_in        <= 0;
            exif.regDst_in          <= 0;
            exif.branch_in          <= 0;
            exif.ALUsrc_in          <= 0;
            exif.memtoReg_in        <= 0;
            exif.jal_in             <= 0;
            exif.jump_in            <= 0;
            exif.rdat1_in           <= 0;
            exif.rdat2_in           <= 0;
            exif.imme_in            <= 0;
            exif.halt_in            <= 0;
            exif.memRead_in         <= 0;
            exif.memWrite_in        <= 0;
            exif.aluOp_in           <= aluop_t'(0);
            exif.datomic_in         <= 0;


            //latch EXE-MEM
            memif.jumpaddr_in       <= 0;
            memif.jump_in           <= 0;
            memif.branchSel_in      <= 0;
            memif.branchaddr_in     <= 0;
            memif.npc_in            <= 0;
            memif.memtoReg_in       <= 0;
            memif.jal_in            <= 0;
            memif.regWrite_in       <= 0;
            memif.aluOut_in         <= 0;
            memif.rdat1_in          <= 0;
            memif.dmemstore_in      <= 0;
            memif.regSel_in         <= 0;
            memif.halt_in           <= 0;
            memif.memRead_in        <= 0;
            memif.memWrite_in       <= 0;
            memif.datomic_in        <= 0;


            //latch MEM-WB
            wbif.npc_in             <= 0;
            wbif.memtoReg_in        <= 0;
            wbif.dmemload_in        <= 0;
            wbif.aluOut_in          <= 0;
            wbif.regSel_in          <= 0;
            wbif.jal_in             <= 0;
            wbif.regWrite_in        <= 0;

        end
        else
        begin

            // latch IF-ID
            idif.npc_in             <= id_npc_in;
            idif.imemload_in        <= id_imemload_in;

            //latch ID-EXE
            exif.npc_in             <= exe_npc_in;
            exif.imemload_in        <= exe_imemload_in;
            exif.regWrite_in        <= exe_regWrite_in;
            exif.regDst_in          <= exe_regDst_in;
            exif.branch_in          <= exe_branch_in;
            exif.ALUsrc_in          <= exe_ALUsrc_in;
            exif.memtoReg_in        <= exe_memtoReg_in;
            exif.jal_in             <= exe_jal_in;
            exif.jump_in            <= exe_jump_in;
            exif.rdat1_in           <= exe_rdat1_in;
            exif.rdat2_in           <= exe_rdat2_in;
            exif.imme_in            <= exe_imme_in;
            exif.halt_in            <= exe_halt_in;
            exif.memRead_in         <= exe_memRead_in;
            exif.memWrite_in        <= exe_memWrite_in;
            exif.aluOp_in           <= exe_aluOp_in;
            exif.datomic_in         <= exe_datomic_in;

            //latch EXE-MEM
            memif.jumpaddr_in       <= mem_jumpaddr_in;
            memif.jump_in           <= mem_jump_in;
            memif.branchSel_in      <= mem_branchSel_in;
            memif.branchaddr_in     <= mem_branchaddr_in;
            memif.npc_in            <= mem_npc_in;
            memif.memtoReg_in       <= mem_memtoReg_in;
            memif.jal_in            <= mem_jal_in;
            memif.regWrite_in       <= mem_regWrite_in;
            memif.aluOut_in         <= mem_aluOut_in;
            memif.rdat1_in          <= mem_rdat1_in;
            memif.dmemstore_in      <= mem_dmemstore_in;
            memif.regSel_in         <= mem_regSel_in;
            memif.halt_in           <= mem_halt_in;
            memif.memRead_in        <= mem_memRead_in;
            memif.memWrite_in       <= mem_memWrite_in;
            memif.datomic_in        <= mem_datomic_in;
            imemload_test           <= n_imemload_test;
            //latch MEM-WB
            wbif.npc_in             <= wb_npc_in;
            wbif.memtoReg_in        <= wb_memtoReg_in;
            wbif.dmemload_in        <= wb_dmemload_in;
            wbif.aluOut_in          <= wb_aluOut_in;
            wbif.regSel_in          <= wb_regSel_in;
            wbif.jal_in             <= wb_jal_in;
            wbif.regWrite_in        <= wb_regWrite_in;

        end
    end



    // next state logic for latch
    always_comb
    begin

        // initialized value for IF-ID latch
        id_npc_in           = idif.npc_in     ;
        id_imemload_in      = idif.imemload_in;



        // initialized value for ID-EXE latch
        exe_npc_in          = exif.npc_in     ;
        exe_imemload_in     = exif.imemload_in;
        exe_regWrite_in     = exif.regWrite_in;
        exe_regDst_in       = exif.regDst_in  ;
        exe_branch_in       = exif.branch_in  ;
        exe_ALUsrc_in       = exif.ALUsrc_in  ;
        exe_memtoReg_in     = exif.memtoReg_in;
        exe_jal_in          = exif.jal_in     ;
        exe_jump_in         = exif.jump_in    ;
        exe_rdat1_in        = exif.rdat1_in;
        exe_rdat2_in        = exif.rdat2_in;
        exe_imme_in         = exif.imme_in ;
        exe_halt_in         = exif.halt_in    ;
        exe_memRead_in      = exif.memRead_in ;
        exe_memWrite_in     = exif.memWrite_in;
        exe_aluOp_in        = exif.aluOp_in   ;
        exe_datomic_in      = exif.datomic_in;


        // initialized value for EXE-MEM latch
        mem_jumpaddr_in     = memif.jumpaddr_in ;
        mem_jump_in         = memif.jump_in     ;
        mem_branchSel_in    = memif.branchSel_in;
        mem_branchaddr_in   = memif.branchaddr_in;
        mem_npc_in          = memif.npc_in      ;
        mem_memtoReg_in     = memif.memtoReg_in ;
        mem_jal_in          = memif.jal_in      ;
        mem_regWrite_in     = memif.regWrite_in ;
        mem_aluOut_in       = memif.aluOut_in   ;
        mem_rdat1_in        = memif.rdat1_in    ;
        mem_dmemstore_in    = memif.dmemstore_in;
        mem_regSel_in       = memif.regSel_in   ;
        mem_halt_in         = memif.halt_in     ;
        mem_memRead_in      = memif.memRead_in  ;
        mem_memWrite_in     = memif.memWrite_in  ;
        mem_datomic_in      = memif.datomic_in;
        n_imemload_test     = imemload_test;


        // initialized vaue for MEM-WB latch
        wb_npc_in           = wbif.npc_in     ;
        wb_memtoReg_in      = wbif.memtoReg_in;
        wb_dmemload_in      = wbif.dmemload_in;
        wb_aluOut_in        = wbif.aluOut_in  ;
        wb_regSel_in        = wbif.regSel_in  ;
        wb_jal_in           = wbif.jal_in     ;
        wb_regWrite_in      = wbif.regWrite_in;






//**************below is the logic for each latch**********


//***************************************************************
//****************IF to ID latch logic*************************8
        if(if_id_en && !hdif.flush_if)
        begin
            id_npc_in           = ifif.npc_out;
            id_imemload_in      = ifif.imemload_out;
        end


        // flush logic
        if(hdif.flush_if && if_id_en)
        begin
            id_npc_in           = '0;
            id_imemload_in      = '0;
        end
//***************************************************************



//***************************************************************
//****************ID to EXE latch logic*************************8
        if(id_ex_en && !hdif.flush_id)
        begin
            exe_npc_in          = idif.npc_out     ;
            exe_imemload_in     = idif.imemload_out;
            exe_regWrite_in     = idif.regWrite_out;
            exe_regDst_in       = idif.regDst_out  ;
            exe_branch_in       = idif.branch_out  ;
            exe_ALUsrc_in       = idif.alusrc_out  ;
            exe_memtoReg_in     = idif.memtoReg_out;
            exe_jal_in          = idif.jal_out     ;
            exe_jump_in         = idif.jump_out    ;
            exe_rdat1_in        = idif.rdat1_out;
            exe_rdat2_in        = idif.rdat2_out;
            exe_imme_in         = idif.imme_out ;
            exe_halt_in         = idif.halt_out    ;
            exe_memRead_in      = idif.memRead_out ;
            exe_memWrite_in     = idif.memWrite_out;
            exe_aluOp_in        = idif.aluOp_out   ;
            exe_datomic_in      = idif.datomic_out;
        end

        // flush logic
        if(id_ex_en && hdif.flush_id)
        begin
            exe_npc_in          = 0;
            exe_imemload_in     = 0;
            exe_regWrite_in     = 0;
            exe_regDst_in       = 0;
            exe_branch_in       = 0;
            exe_ALUsrc_in       = 0;
            exe_memtoReg_in     = 0;
            exe_jal_in          = 0;
            exe_jump_in         = 0;
            exe_rdat1_in        = 0;
            exe_rdat2_in        = 0;
            exe_imme_in         = 0;
            exe_halt_in         = 0;
            exe_memRead_in      = 0;
            exe_memWrite_in     = 0;
            exe_aluOp_in        = aluop_t'(0);
            exe_datomic_in      = 0;
        end
//***************************************************************



//***************************************************************
//***************EXE to MEM latch logic*************************
        if(dpif.dhit)
        begin
            mem_memRead_in      = 0;
            mem_memWrite_in     = 0;
        end

        if(ex_mem_en && !hdif.flush_ex)
        begin
            mem_jumpaddr_in     = exif.jumpaddr_out ;
            mem_jump_in         = exif.jump_out     ;
            mem_branchSel_in    = exif.branchSel_out;
            mem_branchaddr_in   = exif.branchaddr_out;
            mem_npc_in          = exif.npc_out      ;
            mem_memtoReg_in     = exif.memtoReg_out ;
            mem_jal_in          = exif.jal_out      ;
            mem_regWrite_in     = exif.regWrite_out ;
            mem_aluOut_in       = exif.aluOut_out   ;
            mem_rdat1_in        = exif.rdat1_out    ;
            mem_dmemstore_in    = exif.rdat2_out    ;
            mem_regSel_in       = exif.regSel_out   ;
            mem_halt_in         = exif.halt_out     ;
            mem_memRead_in      = exif.memRead_out  ;
            mem_memWrite_in     = exif.memWrite_out ;
            mem_datomic_in      = exif.datomic_out  ;
            n_imemload_test     = exif.imemload_in;
        end
        // flush logic
        if(ex_mem_en && hdif.flush_ex)
        begin
            mem_jumpaddr_in     = 0;
            mem_jump_in         = 0;
            mem_branchSel_in    = 0;
            mem_branchaddr_in   = 0;
            mem_npc_in          = 0;
            mem_memtoReg_in     = 0;
            mem_jal_in          = 0;
            mem_regWrite_in     = 0;
            mem_aluOut_in       = 0;
            mem_rdat1_in        = 0;
            mem_dmemstore_in    = 0;
            mem_regSel_in       = 0;
            mem_halt_in         = 0;
            mem_memRead_in      = 0;
            mem_memWrite_in     = 0;
            mem_datomic_in      = 0;
            n_imemload_test     = 0;
        end
//***************************************************************



//***************************************************************
//****************MEM to WB latch logic*************************
        if(mem_wb_en)
        begin
            wb_npc_in           = memif.npc_out     ;
            wb_memtoReg_in      = memif.memtoReg_out;
            wb_dmemload_in      = memif.dmemload_out;
            wb_aluOut_in        = memif.aluOut_out  ;
            wb_regSel_in        = memif.regSel_out  ;
            wb_jal_in           = memif.jal_out     ;
            wb_regWrite_in      = memif.regWrite_out;
        end

    end
//***************************************************************
//**********************above is pipeline latch section**********//////





    /////////////////////////block signals for cpu tracker////////////////////////////
    word_t imemload_wb, imemload_id, imemload_ex, imemload_mem;
    funct_t funct;
    assign funct = funct_t'(imemload_wb[5:0]);
    opcode_t opcode;
    assign opcode = opcode_t'(imemload_wb[31:26]);
    word_t pc_wb, pc_id, pc_ex, pc_mem;
    word_t npc_wb, npc_id, npc_ex, npc_mem;
    word_t imme_wb, imme_ex, imme_mem;
    word_t baddr_wb;
    word_t dmemstore_wb;
    //cpu tracker only
    //logic halt_wb;
    //logic ihit_wb;

    always_ff @ (posedge CLK, negedge nRST)
    begin
        if(~nRST)
        begin
            imemload_wb <= 0;
            pc_wb <= 0;
            npc_wb <= 0;
            imme_wb <= 0;
            baddr_wb <= 0;
            dmemstore_wb <= 0;
            //cpu tracker only
            //halt_wb <= 0;
            //ihit_wb <= 0;
        end
        else if (dpif.ihit)//|ihit_wb)
        begin
            imemload_id <= ifif.imemload_out;
            imemload_ex <= imemload_id;
            imemload_mem <= imemload_ex;
            imemload_wb <= imemload_mem;

            pc_id <=ifif.imemaddr_out;
            pc_ex <= pc_id;
            pc_mem <= pc_ex;
            pc_wb <= pc_mem;

            npc_id <= ifif.npc_out;
            npc_ex <= npc_id;
            npc_mem <= npc_ex;
            npc_wb <= npc_mem;

            imme_ex <= idif.imme_out;
            imme_mem <= imme_ex;
            imme_wb <= imme_mem;

            baddr_wb <= memif.branchaddr_out;

            dmemstore_wb <= memif.dmemstore_out;
            //cpu tracker only
            //halt_wb <= memif.halt_out;
            //ihit_wb <= dpif.ihit;
        end
    end
    /////////////////////////////////////////////////////////////////
endmodule
