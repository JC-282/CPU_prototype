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
    datapath_cache_if.dcache dcif,
    caches_if.dcache cifd
);
    typedef enum logic[4:0]
    {
        IDEAL, FLUSH, LOAD, WRITE,
        LW, F_FLUSH1, F_FLUSH2, F_FLUSH3,
        F_FLUSH4, F_HITRATE, FF,INV,M_S,
        INV1, M_S1, DUMMY, DUMMY1
    } dstate;


    word_t n_daddr, n_dstore, nn_daddr, nn_dstore;
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            n_daddr <= 0;
            n_dstore <= 0;
        end
        else
        begin
            n_daddr <= nn_daddr;
            n_dstore <= nn_dstore;
        end
    end


    // cache data
    dcache_frame [1:0] [7:0] entry, n_entry;
    logic [32:0] linkreg, n_linkreg;
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
    //logic n_write; //test
    //word_t n_ramaddr, nn_ramaddr, n_ramstore, nn_ramstore;
    /*always_ff @ (posedge CLK, negedge nRST)
    begin
        if(~nRST)
        begin
            n_ramaddr <= 0;
            n_ramstore <= 0;
        end
        else
        begin
            n_ramaddr <= nn_ramaddr;
            n_ramstore <= nn_ramstore;
        end
    end*/
    logic [7:0] lru, n_mru, mru;
    assign lru = ~mru;
    //assign rollover = (count == 1);
    assign rollover8 = (count1 == 7);

    logic match, match_snoop;
    dcachef_t address, address_snoop;
    //logic validLoc;

    ///////////////////////////////////////////////////////////////////////////
    /* This part is for test the hit rate
    logic [31:0] hitcount;
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            hitcount <= 0;
        end
        else if (state == IDEAL && (dcif.dhit && (prev_roll != 1) && dcif.halt != 1 || (match && dcif.dmemWEN)))
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
*/

    //assign local variables
    //assign validLoc = entry[address.idx].valid;
    assign address = dcachef_t'(dcif.dmemaddr);
    assign address_snoop = dcachef_t'(cifd.ccsnoopaddr);

    assign match = (address.tag == entry[0][address.idx].tag && entry[0][address.idx].valid == 1
                        || address.tag == entry[1][address.idx].tag && entry[1][address.idx].valid);

    assign match_snoop = (cifd.ccsnoopaddr[31:6] == entry[0][cifd.ccsnoopaddr[5:3]].tag && entry[0][cifd.ccsnoopaddr[5:3]].valid == 1) ||  (cifd.ccsnoopaddr[31:6] == entry[1][cifd.ccsnoopaddr[5:3]].tag && entry[1][cifd.ccsnoopaddr[5:3]].valid == 1 );
    //daddress is always connected
    //assign cifd.daddr = dcif.dmemaddr;
    //assign dcif.dmemload = () ? entry[0][address.idx].data[address.blkoff] : ;
    //assign dcif.dmemload = entry[1][address.idx].data[address.blkoff];
    logic position;
    //assign position = (entry[0][address.idx].tag == address.tag) ? 0 : 1; it should be wrong
    assign position = (entry[0][address_snoop.idx].valid && (entry[0][address_snoop.idx].tag == address_snoop.tag)) ? 0 : 1;

    always_comb
    begin
        if (dcif.datomic && ~dcif.dmemREN)
        begin
            if ((dcif.dmemaddr == linkreg[31:0]) && linkreg[32])
                dcif.dmemload = 1;
            else
                dcif.dmemload = 0;
        end
        else if (entry[0][address.idx].tag == address.tag && entry[0][address.idx].valid)
        begin
            dcif.dmemload = entry[0][address.idx].data[address.blkoff];
        end
        else
        begin
            dcif.dmemload = entry[1][address.idx].data[address.blkoff];
        end
    end


    always_comb
    begin
        if (cifd.ccsnoopaddr[1] == 0)
            cifd.ccwrite = cifd.ccwait ?  match_snoop && (entry[position][cifd.ccsnoopaddr[5:3]].dirty) : (dcif.dmemWEN && (state != IDEAL));
        else
            cifd.ccwrite = cifd.ccwait ?  match_snoop : (dcif.dmemWEN && (state != IDEAL));

        if (state == FF) cifd.ccwrite = 0;
    end

/*    //test modify///////////////////////
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if(~nRST)
        begin
            cifd.ccwrite <= 0;
        end
            cifd.ccwrite <= n_write;
    end
*/
    ////////////////////////////////////
    // the cache frames
    always_ff @ (posedge CLK, negedge nRST)
    begin
        if (~nRST)
        begin
            entry <= '0;
            mru <= '0;
            linkreg <= '0;
        end
        else
        begin
            entry <= n_entry;
            mru <= n_mru;
            linkreg <= n_linkreg;
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
        dcif.flushed = 0;
        case (state)
            IDEAL:
            begin

                if(cifd.ccwait && match_snoop && ~cifd.ccinv && ~cifd.ccsnoopaddr[0] && (entry[position][cifd.ccsnoopaddr[5:3]].dirty))
                begin
                    n_state = DUMMY;
                end
                else if(cifd.ccinv && cifd.ccwait && match_snoop && ~cifd.ccsnoopaddr[0])
                begin
                    n_state = INV;
                end

                if (dcif.halt && ~cifd.ccwait)
                begin
                    n_state = F_FLUSH1;
                end
                if ((dcif.dmemREN || dcif.dmemWEN) && ~cifd.ccwait)
                begin
                    if (match && dcif.dmemREN)
                    begin
                        n_state = IDEAL;
                    end
                    else if (match && dcif.dmemWEN)
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

                if(dcif.datomic && !dcif.dmemload && dcif.dmemWEN && ~cifd.ccwait)
                begin
                    n_state = IDEAL;
                end


                if(~cifd.ccwait && cifd.ccinv)
                begin
                    n_state = IDEAL;
                end

            end
            LOAD:
            begin
                if(cifd.ccwait == 1)
                begin
                    n_state = IDEAL;
                end
                else if (dcif.dmemREN && (count == 1 && ~cifd.dwait))
                begin
                    n_state = IDEAL;
                end
                else if (dcif.dmemWEN && (count == 1 && ~cifd.dwait))
                begin
                    n_state = WRITE;
                end
            end
            WRITE:
            begin
                if(cifd.ccwait == 1)
                begin
                    n_state = IDEAL;
                end
                else
                begin
                    n_state = LW;
                end
            end
            FLUSH:
            begin
                if(cifd.ccwait == 1)
                begin
                    n_state = IDEAL;
                end
                else if (count == 1 && ~cifd.dwait) n_state = LOAD;
            end
            LW:
            begin
                if(cifd.ccinv && ~cifd.ccwait)
                begin
                    n_state = state;
                end
                else //if(cifd.ccsnoopaddr[1] == 0) // nm modify
                    n_state = IDEAL; // modify on Friday
                    //n_state = DUMMY; // modify on Friday
            end
            F_FLUSH1:
            begin
                if(cifd.ccwait == 1)
                begin
                    n_state = IDEAL;
                end
                else if (rollover8 && (~cifd.dwait || invalidF)) n_state = F_FLUSH2;
                //if (rollover8) n_state = F_FLUSH2;
            end
            F_FLUSH2:
            begin
                if(cifd.ccwait == 1)
                begin
                    n_state = IDEAL;
                end
                if (rollover8 && (~cifd.dwait || invalidF)) n_state = F_FLUSH3;
                //if (rollover8) n_state = F_FLUSH3;
            end
            F_FLUSH3:
            begin
                if(cifd.ccwait == 1)
                begin
                    n_state = IDEAL;
                end
                if (rollover8 && (~cifd.dwait || invalidF)) n_state = F_FLUSH4;
                //if (rollover8) n_state = F_FLUSH4;
            end
            F_FLUSH4:
            begin
                if(cifd.ccwait == 1)
                begin
                    n_state = IDEAL;
                end
                if (rollover8 && (~cifd.dwait || invalidF)) n_state = FF;//F_HITRATE;
            end
                //if (rollover8) dcif.flushed = 1;
            /*F_HITRATE:
                if (~cifd.dwait) n_state = FF;
            */
            FF:
            begin
                dcif.flushed = 1;

            end
            INV:
            begin
                if(n_daddr[0] == 1)
                    n_state = DUMMY1;
                if(cifd.ccsnoopaddr[1] == 1)
                    n_state = INV1;
            end
            DUMMY1:
                n_state = INV1;
            INV1:
            begin
                if(n_daddr[1] == 1)
                    n_state = IDEAL;
            end

            DUMMY:
                n_state = M_S;
            M_S:
            begin
                if(~cifd.dwait)
                begin
                    n_state = M_S1;
                end
            end


            M_S1:
            begin
                if(~cifd.dwait)
                begin
                    n_state = IDEAL;
                end
            end
        endcase
    end

    // output logic
    always_comb
    begin
        n_linkreg[31:0] = (dcif.datomic && dcif.dmemREN) ? dcif.dmemaddr : linkreg[31:0];
        n_linkreg[32] = (dcif.datomic && dcif.dmemREN) ? 1 : linkreg[32];
        nn_daddr = n_daddr;
        nn_dstore = n_dstore;
        enable_counter = 0;
        enable_counter1 = 0;
        cifd.dREN = 0;
        cifd.dWEN = 0;
        n_entry = entry;
        //cifd.daddr = '0;
        cifd.daddr = {dcif.dmemaddr[31:3], 1'b0,2'b00};//'0;
        cifd.dstore = '0;
        dcif.dhit = 0;
        invalidF = 0;
        n_mru = mru;
        cifd.cctrans = 1;
        //cifd.ccwrite = dcif.dmemWEN;
        case(state)
            F_FLUSH1:
            begin
                enable_counter1 = 1;
                cifd.daddr = word_t'({entry[0][count1].tag, count1,1'b1,2'b1});
                if (entry[0][count1].valid)
                begin
                    cifd.dWEN = 1;
                    cifd.dstore = entry[0][count1].data[1];
                end
                else
                    invalidF = 1;
            end
            F_FLUSH2:
            begin
                enable_counter1 = 1;
                cifd.daddr = word_t'({entry[0][count1].tag, count1,1'b0,2'b1});
                if (entry[0][count1].valid)
                begin
                    cifd.dWEN = 1;
                    cifd.dstore = entry[0][count1].data[0];
                end
                else
                    invalidF = 1;
            end
            F_FLUSH3:
            begin
                enable_counter1 = 1;
                cifd.daddr = word_t'({entry[1][count1].tag, count1,1'b1,2'b1});
                if (entry[1][count1].valid)
                begin
                    cifd.dWEN = 1;
                    cifd.dstore = entry[1][count1].data[1];
                end
                else
                    invalidF = 1;
            end
            F_FLUSH4:
            begin
                enable_counter1 = 1;
                cifd.daddr = word_t'({entry[1][count1].tag, count1,1'b0,2'b1});
                if (entry[1][count1].valid)
                begin
                    cifd.dWEN = 1;
                    cifd.dstore = entry[1][count1].data[0];
                end
                else
                    invalidF = 1;
            end
            /*
            F_HITRATE:
            begin
                cifd.dWEN = 1;
                cifd.daddr = word_t'(32'h3100);
                cifd.dstore = word_t'(hitcount);
            end
            */
            IDEAL:
            begin
                if(dcif.datomic && !dcif.dmemload && dcif.dmemWEN && ~cifd.ccwait)
                begin
                    dcif.dhit = 1;
                end
                if (cifd.ccwait && cifd.ccinv && (cifd.ccsnoopaddr[31:2] == linkreg[31:2]) && ~(cifd.ccinv && ~cifd.ccwait))
                    begin
                        n_linkreg[32] = 0;
                    end
                cifd.cctrans = 0;
                //cifd.ccwrite = match_snoop && (entry[position][cifd.ccsnoopaddr[5:3]].dirty);
                if (dcif.dmemREN && match && (dcif.halt != 1) && ~cifd.ccwait)
                begin
                    dcif.dhit = 1;
                    if (entry[0][address.idx].tag == address.tag)
                    begin
                        n_mru[address.idx] = 0;
                    end
                    else
                    begin
                        n_mru[address.idx] = 1;
                    end
                end
                if(cifd.ccinv && ~cifd.ccwait)
                begin
                    dcif.dhit = 0;
                end

            end
            LW:
            begin
                //invalid the linkreg by itself
               // cifd.cctrans = 0;
                if(dcif.dmemWEN && (dcif.dmemaddr == linkreg[31:0]) && ~(cifd.ccinv && ~cifd.ccwait))
                begin
                    n_linkreg[32] = 0;
                end

                if(/*cifd.ccsnoopaddr[1] == 0 &&*/ ~(cifd.ccinv && ~cifd.ccwait))
                    dcif.dhit = 1;
                else
                    dcif.dhit = 0;

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
                cifd.daddr = {dcif.dmemaddr[31:3], count[0],2'b00};
                if(~entry[mru[address.idx]][address.idx].valid && entry[lru[address.idx]][address.idx].valid)
                begin
                    if(count == 1 && ~cifd.dwait)
                    begin
                        n_entry[mru[address.idx]][address.idx].tag = address.tag;
                        n_entry[mru[address.idx]][address.idx].valid = 1;
                    end
                    if(~cifd.dwait)
                        n_entry[mru[address.idx]][address.idx].data[count[0]] = cifd.dload;
                end
                else
                begin
                    if(count == 1 && ~cifd.dwait)
                    begin
                        n_entry[lru[address.idx]][address.idx].tag = address.tag;
                        n_entry[lru[address.idx]][address.idx].valid = 1;
                    end
                    if(~cifd.dwait)
                        n_entry[lru[address.idx]][address.idx].data[count[0]] = cifd.dload;
                end
            end

            WRITE:
            begin
                cifd.daddr = {dcif.dmemaddr[31:3], 1'b0,2'b00};
                if(entry[0][address.idx].tag == address.tag && entry[0][address.idx].valid)
                begin
                    n_entry[0][address.idx].data[address.blkoff] = dcif.dmemstore;
                    n_entry[0][address.idx].dirty = 1;
                end
                else
                begin
                    n_entry[1][address.idx].data[address.blkoff] = dcif.dmemstore;
                    n_entry[1][address.idx].dirty = 1;

                end
            end

            FLUSH:
            begin
                enable_counter = 1;
                cifd.dWEN = 1;
                cifd.dstore = entry[lru[address.idx]][address.idx].data[count[0]];
                if(count[0] == 0)
                    cifd.daddr = word_t'({entry[lru[address.idx]][address.idx].tag, address.idx,count[0],2'b1});
                else
                    cifd.daddr = word_t'({entry[lru[address.idx]][address.idx].tag, address.idx,count[0],2'b0});


            end
            INV:
            begin
                if (match_snoop && (entry[position][cifd.ccsnoopaddr[5:3]].dirty))
                begin
                    nn_dstore = entry[position][cifd.ccsnoopaddr[5:3]].data[0];
                    nn_daddr = word_t'(cifd.ccsnoopaddr);
                end
                else
                begin
                    nn_dstore = 0;
                    nn_daddr = {dcif.dmemaddr[31:3], 1'b0,2'b00};
                end
                nn_daddr[0] = 1;
                cifd.dstore = n_dstore;
                if (n_daddr[0] == 1)
                begin
                    cifd.daddr = {n_daddr[31:2], 2'b0};
                end
                else
                begin
                    cifd.daddr = {n_daddr[31:2], 2'b1};
                end
                //n_entry[position][cifd.ccsnoopaddr[5:3]].valid = 0;
            end
            DUMMY1:
            begin
                cifd.cctrans = 0;
            end
            INV1:
            begin
                if (match_snoop && (entry[position][cifd.ccsnoopaddr[5:3]].dirty))
                begin
                    nn_dstore = entry[position][cifd.ccsnoopaddr[5:3]].data[1];
                    nn_daddr = word_t'(cifd.ccsnoopaddr);
                end
                else
                begin
                    nn_dstore = 0;
                    nn_daddr = {dcif.dmemaddr[31:3], 1'b0,2'b00};
                end
                nn_daddr[1] = 1'b1;
                nn_daddr[0] = 1'b0;

                cifd.dstore = n_dstore;
                if (n_daddr[1] == 1)
                begin
                    n_entry[position][cifd.ccsnoopaddr[5:3]].valid = 0;
                    cifd.daddr = {n_daddr[31:2], 2'b0};
                end
                else
                begin
                    cifd.daddr = {n_daddr[31:2], 1'b1, 1'b0};
                end

            end
            DUMMY:
            begin
                cifd.cctrans = 0;
                nn_daddr = word_t'({entry[position][cifd.ccsnoopaddr[5:3]].tag, cifd.ccsnoopaddr[5:3],1'b0,2'b0});
                nn_dstore = entry[position][cifd.ccsnoopaddr[5:3]].data[0];
            end

            M_S:
            begin
                if (~cifd.dwait)
                begin
                    nn_daddr = word_t'({entry[position][cifd.ccsnoopaddr[5:3]].tag, cifd.ccsnoopaddr[5:3],1'b1,2'b0});
                    nn_dstore = entry[position][cifd.ccsnoopaddr[5:3]].data[1];
                end
                cifd.dstore = n_dstore;
                cifd.daddr = n_daddr;
            end
            M_S1:
            begin
                cifd.dstore = n_dstore;
                cifd.daddr = n_daddr;
                n_entry[position][cifd.ccsnoopaddr[5:3]].dirty = 0;
            end
            FF:
            begin
                cifd.cctrans = 0;
                cifd.daddr[1] = 1;
            end

        endcase
    end
endmodule

