// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: source file
// description: the source file for the dcache
`include "caches_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module dcache
(
    input logic CLK, nRST,
    datapath_cache_if.dcache dcifd,
    caches_if.dcache cifd
);
    typedef enum logic[3:0]
    {
        IDEAL, FLUSH, LOAD, WRITE, LW, F_FLUSH1, F_FLUSH2, F_FLUSH3, F_FLUSH4, F_HITRATE, FF
    } dstate;




    // cache data
    dcache_frame [1:0] [7:0] entry, n_entry;
    // the state for controller
    dstate state, n_state;
    // logic for counter
    logic [1:0] count;
    logic [2:0] count1;
    //logic rollover;
    logic enable_counter;
    logic enable_counter1;
    logic invalidF;
    logic rollover8;
    logic prev_roll; // This is the prev_roll for distinguish the hit rate from different state



    logic [7:0] lru, n_mru, mru;
    assign lru = ~mru;
    //assign rollover = (count == 1);
    assign rollover8 = (count1 == 7);

    logic match;
    dcachef_t address;
    //logic validLoc;

    ///////////////////////////////////////////////////////////////////////////
    /* This part is for test the hit rate*/
    logic [31:0] hitcount;
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            hitcount <= 0;
        end
        else if (state == IDEAL && (dcifd.dhit && (prev_roll != 1) && dcifd.halt != 1 || (match && dcifd.dmemWEN)))
        begin
            hitcount <= hitcount + 1;
        end
        else
        begin
            hitcount <= hitcount;
        end
    end
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            prev_roll <= 0;
        end
        else
        begin
            prev_roll <= count;
        end
    end
    //////////////////////////////////////////////////////////////////////////////


    //assign local variables
    //assign validLoc = entry[address.idx].valid;
    assign address = dcachef_t'(dcifd.dmemaddr);

    assign match = (address.tag == entry[0][address.idx].tag && entry[0][address.idx].valid == 1
                        || address.tag == entry[1][address.idx].tag && entry[1][address.idx].valid);

    //daddress is always connected
    //assign cifd.daddr = dcifd.dmemaddr;
    assign dcifd.dmemload = (entry[0][address.idx].tag == address.tag) ? entry[0][address.idx].data[address.blkoff] : entry[1][address.idx].data[address.blkoff];
    //assign dcifd.dmemload = entry[1][address.idx].data[address.blkoff];

    // the cache frames
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            entry <= '0;
            mru <= '0;
        end
        else
        begin
            entry <= n_entry;
            mru <= n_mru;
        end
    end

    // the cache controller
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            state <= IDEAL;
        end
        else
        begin
            state <= n_state;
        end
    end



    // counter for COUNT 2
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
           count <= 0;
        end
        else if (~enable_counter)
        begin
           count <= 0;
        end
        else if (~cifd.dwait)
        begin
            if (count == 1) count <= 0;
            else count <= count + 1;
        end
        else
        begin
            count <= count;
        end
    end




    // counter for final flush
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
           count1 <= 0;
        end
        else if (~enable_counter1)
        begin
           count1 <= 0;
        end
        else if (~cifd.dwait || invalidF)
        begin
           if (count1 == 7) count1 <= 0;
           else count1 <= count1 + 1;
        end
        else
        begin
            count1 <= count1;
        end
    end



    // next state logic
    always_comb
    begin
        n_state = state;
        dcifd.flushed = 0;
        case (state)
            IDEAL:
            begin
                if (dcifd.halt)
                begin
                    n_state = F_FLUSH1;
                end
                if (dcifd.dmemREN || dcifd.dmemWEN)
                begin
                    if (match && dcifd.dmemREN)
                    begin
                        n_state = IDEAL;
                    end
                    else if (match && dcifd.dmemWEN)
                    begin
                        n_state = WRITE;
                    end
                    else if (~match
                        && entry[0][address.idx].valid
                        && entry[1][address.idx].valid
                        && entry[lru[address.idx]][address.idx].dirty)
                    begin
                        n_state = FLUSH;
                    end
                    else
                    begin
                        n_state = LOAD;
                    end
                end
            end
            LOAD:
            begin
                if (dcifd.dmemREN && (count == 1 && ~cifd.dwait))
                begin
                    n_state = IDEAL;
                end
                else if (dcifd.dmemWEN && (count == 1 && ~cifd.dwait))
                begin
                    n_state = WRITE;
                end
            end
            WRITE:
            begin
                n_state = LW;
            end
            FLUSH:
            begin
                if (count == 1 && ~cifd.dwait) n_state = LOAD;
            end
            LW:
            begin
                n_state = IDEAL;
            end
            F_FLUSH1:
                if (rollover8 && (~cifd.dwait || invalidF)) n_state = F_FLUSH2;
                //if (rollover8) n_state = F_FLUSH2;
            F_FLUSH2:
                if (rollover8 && (~cifd.dwait || invalidF)) n_state = F_FLUSH3;
                //if (rollover8) n_state = F_FLUSH3;
            F_FLUSH3:
                if (rollover8 && (~cifd.dwait || invalidF)) n_state = F_FLUSH4;
                //if (rollover8) n_state = F_FLUSH4;
            F_FLUSH4:
                if (rollover8 && (~cifd.dwait || invalidF)) n_state = F_HITRATE;
                //if (rollover8) dcifd.flushed = 1;
            F_HITRATE:
                if (~cifd.dwait) n_state = FF;
            FF: dcifd.flushed = 1;


        endcase
    end

    // output logic
    always_comb
    begin
        enable_counter = 0;
        enable_counter1 = 0;
        cifd.dREN = 0;
        cifd.dWEN = 0;
        n_entry = entry;
        cifd.daddr = '0;
        cifd.dstore = '0;
        dcifd.dhit = 0;
        invalidF = 0;
        n_mru = mru;
        case(state)
            F_FLUSH1:
            begin
                enable_counter1 = 1;
                if (entry[0][count1].valid)
                begin
                    cifd.dWEN = 1;
                    cifd.daddr = word_t'({entry[0][count1].tag, count1,1'b1,2'b0});
                    cifd.dstore = entry[0][count1].data[1];
                end
                else
                    invalidF = 1;
            end
            F_FLUSH2:
            begin
                enable_counter1 = 1;
                if (entry[0][count1].valid)
                begin
                    cifd.dWEN = 1;
                    cifd.daddr = word_t'({entry[0][count1].tag, count1,1'b0,2'b0});
                    cifd.dstore = entry[0][count1].data[0];
                end
                else
                    invalidF = 1;
            end
            F_FLUSH3:
            begin
                enable_counter1 = 1;
                if (entry[1][count1].valid)
                begin
                    cifd.dWEN = 1;
                    cifd.daddr = word_t'({entry[1][count1].tag, count1,1'b1,2'b0});
                    cifd.dstore = entry[1][count1].data[1];
                end
                else
                    invalidF = 1;
            end
            F_FLUSH4:
            begin
                enable_counter1 = 1;
                if (entry[1][count1].valid)
                begin
                    cifd.dWEN = 1;
                    cifd.daddr = word_t'({entry[1][count1].tag, count1,1'b0,2'b0});
                    cifd.dstore = entry[1][count1].data[0];
                end
                else
                    invalidF = 1;
            end
            F_HITRATE:
            begin
                cifd.dWEN = 1;
                cifd.daddr = word_t'(32'h3100);
                cifd.dstore = word_t'(hitcount);
            end
            IDEAL:
            begin
                if (dcifd.dmemREN && match && dcifd.halt != 1)
                begin
                    dcifd.dhit = 1;
                    if (entry[0][address.idx].tag == address.tag)
                    begin
                        n_mru[address.idx] = 0;
                    end
                    else
                    begin
                        n_mru[address.idx] = 1;
                    end
                end
            end
            LW:
            begin
                dcifd.dhit = 1;
                if (entry[0][address.idx].tag == address.tag)
                begin
                    n_mru[address.idx] = 0;
                end
                else
                begin
                    n_mru[address.idx] = 1;
                end
            end
            LOAD:
            begin
                enable_counter = 1;
                cifd.dREN = 1;
                cifd.daddr = {dcifd.dmemaddr[31:3], count[0],2'b00};
                if(~entry[mru[address.idx]][address.idx].valid && entry[lru[address.idx]][address.idx].valid)
                begin
                    if(count == 1 && ~cifd.dwait)
                    begin
                        n_entry[mru[address.idx]][address.idx].tag = address.tag;
                        n_entry[mru[address.idx]][address.idx].valid = 1;
                    end
                    n_entry[mru[address.idx]][address.idx].data[count[0]] = cifd.dload;
                end
                else
                begin
                    if(count == 1 && ~cifd.dwait)
                    begin
                        n_entry[lru[address.idx]][address.idx].tag = address.tag;
                        n_entry[lru[address.idx]][address.idx].valid = 1;
                    end
                    n_entry[lru[address.idx]][address.idx].data[count[0]] = cifd.dload;
                end
            end

            WRITE:
            begin
                if(entry[0][address.idx].tag == address.tag)
                begin
                    n_entry[0][address.idx].data[address.blkoff] = dcifd.dmemstore;
                    n_entry[0][address.idx].dirty = 1;
                end
                else
                begin
                    n_entry[1][address.idx].data[address.blkoff] = dcifd.dmemstore;
                    n_entry[1][address.idx].dirty = 1;

                end
            end

            FLUSH:
            begin
                enable_counter = 1;
                cifd.dWEN = 1;
                cifd.daddr = word_t'({entry[lru[address.idx]][address.idx].tag, address.idx,count[0],2'b0});
                cifd.dstore = entry[lru[address.idx]][address.idx].data[count[0]];
            end

        endcase
    end
endmodule

