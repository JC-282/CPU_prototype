// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: source file
// description: this is branch target buffer prototype (not tested)


module btb
(
    input logic CLK, nRST,
    output logic hit,
    output logic [31:0] predict_out
);

    logic branch; // whether finally branch to other or not(not npc)
    word_t pc; // This is the pc from mem stage
    word_t npc; // This is the branch targe address from mem stage
    word_t imemaddr; // current imemaddr
    logic valid;
    assign valid = register[imemaddr[3:0]][60];
    assign hit = (register[imemaddr[3:0]][59:32] == imemaddr[31:4] && valid);
    assign predict_out = register[imemaddr[3:0]][31:0];






    logic [60:0] [15:0] register, n_register;

    always_ff @ (negedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            register <= '0;
        end
        else
        begin
            register <= n_register;
        end
    end

    always_comb
    begin
        n_register = register;
        if (branch)
        begin
            n_register[pc[3:0]] = {1'b1,pc[31:4],npc};

        end
    end


endmodule

