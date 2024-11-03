// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: source file
// description: the source file for the icache
`include "caches_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module icache
(
    input logic CLK, nRST,
    datapath_cache_if.icache dcif,
    caches_if.icache cifi
);
    typedef enum logic
    {
        CHECKING, MEM_READ
    } istate;



    //local variable
    logic tag_match;
    icachef_t address;
    logic validLoc;

    // the state for controller
    istate state, n_state;
    // cache data
    icache_frame [15:0] entry, n_entry;

    //assign local variables
    assign validLoc = entry[address.idx].valid;
    assign address = icachef_t'(dcif.imemaddr);
    assign dcif.imemload = entry[address.idx].data;

    assign tag_match = (address.tag == entry[address.idx].tag);



    // the cache frames
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            entry <= '0;
        end
        else
        begin
            entry <= n_entry;
        end
    end

    // the cache controller
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            state <= CHECKING;
        end
        else
        begin
            state <= n_state;
        end
    end
    //next state logic
    always_comb
    begin
        n_state = state;

        case(state)
            CHECKING:
            begin
                if((tag_match == 0 || validLoc == 0) && dcif.imemREN)
                    n_state = MEM_READ;
            end

            MEM_READ:
            begin
                if(~cifi.iwait)
                    n_state = CHECKING;
            end
        endcase
    end

    //output logic
    always_comb
    begin
        cifi.iREN = 0;
        dcif.ihit = 0;
        cifi.iaddr = '0;
        n_entry = entry;
        case(state)
            CHECKING:
            begin
                cifi.iREN = 0;
                dcif.ihit = (tag_match && validLoc);
            end

            MEM_READ:
            begin
                cifi.iREN = 1;
                cifi.iaddr = dcif.imemaddr;

                n_entry[address.idx].tag = address.tag;
                n_entry[address.idx].data = cifi.iload;
                n_entry[address.idx].valid = 1;
            end
        endcase
    end
endmodule

