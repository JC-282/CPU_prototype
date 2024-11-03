/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

// type import
import cpu_types_pkg::*;

module memory_control (
    input CLK, nRST,
    cache_control_if.cc ccif
);

    typedef enum logic [4:0]
    {
        IDLE, IDLE1,
        //first core
        SNOOP_R_0, C_C_STORE_R_0, LOAD_M_R_0,
        SNOOP_RX_0, INV_HIT_RX_0, INV_NHIT_RX_0, C_C_RX_INV0, LOAD_M_RX_0,
        //second core
        SNOOP_R_1, C_C_STORE_R_1, LOAD_M_R_1,
        SNOOP_RX_1, INV_HIT_RX_1, INV_NHIT_RX_1, C_C_RX_INV1, LOAD_M_RX_1,
        //dWEN and icache
        STORE_W_0, LOAD_M_I_0,
        STORE_W_1, LOAD_M_I_1,
        // only ccwrite
        CCWRITE_SNOOP0, CCWRITE_INV0, CCWRITE_INV0_F,
        CCWRITE_SNOOP1, CCWRITE_INV1, CCWRITE_INV1_F
    } Bus_State;
    logic [1:0]n_ccinv;
    word_t[1:0] n_ccsnoopaddr;
    Bus_State state, n_state;
    word_t n_ramstore, n_ramaddr;
    logic n_ramWEN, n_ramREN;
    ramstate_t prev_ramstate;
    logic rams_test;
    assign rams_test = (prev_ramstate != ACCESS && ccif.ramstate == ACCESS);
    //latch for all cc value
    always_ff @ (negedge CLK, negedge nRST)
    begin
        if(~nRST)
            prev_ramstate <= ramstate_t'(0);
        else
            prev_ramstate <= ccif.ramstate;
    end

    always_ff @ (posedge CLK, negedge nRST)
    begin
        if(~nRST)
        begin
            //ccif.ccinv <= 0;
            ccif.ccsnoopaddr <= '0;
            ccif.ramstore <= 0;
            ccif.ramaddr <= 0;
            ccif.ramWEN <= 0;
            ccif.ramREN <= 0;
            //prev_ramstate <= ramstate_t'(0);
        end
        else
        begin
            //ccif.ccinv <= n_ccinv;
            ccif.ccsnoopaddr <= n_ccsnoopaddr;
            ccif.ramstore <= n_ramstore;
            ccif.ramaddr <= n_ramaddr;
            ccif.ramWEN <= n_ramWEN;
            ccif.ramREN <= n_ramREN;
            //prev_ramstate <= ccif.ramstate;
        end
    end

    always_ff @ (posedge CLK, negedge nRST)
    begin
        if(~nRST)
        begin
            state <= IDLE;
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
        IDLE:
        begin
            //go ocache0

            //flush and i access

            if(ccif.iREN[0] && ~ccif.cctrans[0])
                n_state = IDLE1;

            else if(ccif.iREN[1] && ~ccif.cctrans[1])
                n_state = IDLE1;

            if(ccif.dWEN[0])
                n_state = IDLE1;

            else if(ccif.dWEN[1])
                n_state = IDLE1;
            else if(ccif.dREN[0] && ccif.ccwrite[0] && ccif.cctrans[0] == 1)
                n_state = IDLE1;

            else if(ccif.dREN[0] && ~ccif.ccwrite[0] && ccif.cctrans[0] == 1)
                n_state = IDLE1;
            //go cache1
            else if (ccif.ccwrite[0] && ccif.cctrans[0] == 1)
                n_state = IDLE1;
            else if(ccif.dREN[1] && ccif.ccwrite[1] && ccif.cctrans[1] == 1)
                n_state = IDLE1;

            else if(ccif.dREN[1] && ~ccif.ccwrite[1] && ccif.cctrans[1] == 1)
                n_state = IDLE1;
            else if (ccif.ccwrite[1] && ccif.cctrans[1] == 1)
                n_state = IDLE1;

        end

        IDLE1:
        begin
            //go ocache0
            //flush and i access
            if(ccif.iREN[0] && ~ccif.cctrans[0])
                n_state = LOAD_M_I_0;

            else if(ccif.iREN[1] && ~ccif.cctrans[1])
                n_state = LOAD_M_I_1;


            if(ccif.dWEN[0])
                n_state = STORE_W_0;

            else if(ccif.dWEN[1])
                n_state = STORE_W_1;

            else if(ccif.dREN[0] && ccif.ccwrite[0] && ccif.cctrans[0] == 1)
                n_state = SNOOP_RX_0;

            else if(ccif.dREN[0] && ~ccif.ccwrite[0] && ccif.cctrans[0] == 1)
                n_state = SNOOP_R_0;
            //go cache1
            else if (ccif.ccwrite[0] && ccif.cctrans[0] == 1)
                n_state = CCWRITE_SNOOP0;
            else if(ccif.dREN[1] && ccif.ccwrite[1] && ccif.cctrans[1] == 1)
                n_state = SNOOP_RX_1;

            else if(ccif.dREN[1] && ~ccif.ccwrite[1] && ccif.cctrans[1] == 1)
                n_state = SNOOP_R_1;
            else if (ccif.ccwrite[1] && ccif.cctrans[1] == 1)
                n_state = CCWRITE_SNOOP1;

        end
        SNOOP_R_0:
        begin
            if(ccif.ccsnoopaddr[1][0] == 1)
            begin
                if(ccif.ccwrite[1])
                    n_state = C_C_STORE_R_0;
                else
                    n_state = LOAD_M_R_0;
            end
        end

        C_C_STORE_R_0:
        begin
            if(~ccif.cctrans[0] && ~ccif.cctrans[1])//do we need to wait both of trans be 0
                n_state = IDLE;
        end

        LOAD_M_R_0:
        begin
            if(~ccif.cctrans[0])
                n_state = IDLE;
        end

        SNOOP_RX_0:
        begin
            if(ccif.ccsnoopaddr[1][0] == 1)
            begin
                if(ccif.ccwrite[1])
                    n_state = C_C_RX_INV0;
                else
                    n_state = INV_NHIT_RX_0;
            end
        end
        //INV_HIT_RX_0:
        //begin
            //if(~ccif.cctrans[1])
                //n_state = IDLE;
        //end

        INV_NHIT_RX_0:
        begin
            if(~ccif.cctrans[1] && ~ccif.ccsnoopaddr[1][0])
                n_state = LOAD_M_RX_0;
        end

        C_C_RX_INV0:
        begin
            if(~ccif.cctrans[0] && ~ccif.cctrans[1])
                n_state = IDLE;
        end

        LOAD_M_RX_0:
        begin
            if(~ccif.cctrans[0] && ~ccif.cctrans[1])
                n_state = IDLE;
        end

        SNOOP_R_1:
        begin
            if(ccif.ccsnoopaddr[0][0] == 1)
            begin
                if(ccif.ccwrite[0])
                    n_state = C_C_STORE_R_1;
                else
                    n_state = LOAD_M_R_1;
            end
        end

        C_C_STORE_R_1:
        begin
            if(~ccif.cctrans[1] && ~ccif.cctrans[0])
                n_state = IDLE;
        end

        LOAD_M_R_1:
        begin
            if(~ccif.cctrans[1])
                n_state = IDLE;
        end

        SNOOP_RX_1:
        begin
            if(ccif.ccsnoopaddr[0][0] == 1)
            begin
                if(ccif.ccwrite[0])
                    n_state = C_C_RX_INV1;
                else
                    n_state = INV_NHIT_RX_1;
            end
        end

        //INV_HIT_RX_1:
        //begin
            //if(~ccif.cctrans[0])
                //n_state = IDLE;
        //end

        INV_NHIT_RX_1:
        begin
            if(~ccif.cctrans[0] && ~ccif.ccsnoopaddr[0][0])
                n_state = LOAD_M_RX_1;
        end

        C_C_RX_INV1:
        begin
            if(~ccif.cctrans[1] && ~ccif.cctrans[0])
                n_state = IDLE;
        end

        LOAD_M_RX_1:
        begin
            if(~ccif.cctrans[1] && ~ccif.cctrans[0])
                n_state = IDLE;
        end

        STORE_W_0:
        begin
            if(ccif.daddr[0][0] == 1)
                n_state = state;
            //else if(ccif.ramstate == ACCESS || ccif.daddr[0][1] == 1)
            else if(rams_test || ccif.daddr[0][1] == 1)
                n_state = IDLE;
        end

        LOAD_M_I_0:
        begin
            if(ccif.ramstate == ACCESS)
            //if(rams_test)
                n_state = IDLE;
        end

        STORE_W_1:
        begin
            if(ccif.daddr[1][0] == 1)
                n_state = state;
            //else if(ccif.ramstate == ACCESS || ccif.daddr[1][1] == 1)
            else if(rams_test || ccif.daddr[1][1] == 1)
                n_state = IDLE;
        end

        LOAD_M_I_1:
        begin
            if(ccif.ramstate == ACCESS)
            //if(rams_test)
                n_state = IDLE;
        end
        CCWRITE_SNOOP0:
        begin
            if(ccif.ccsnoopaddr[1][0] == 1)
            begin
                if(ccif.ccwrite[1] && ccif.cctrans[1] == 0)
                    n_state = CCWRITE_INV0;
                else if (ccif.ccwrite[1] == 0 && ccif.cctrans[1] == 0)
                    n_state = IDLE;
            end
        end
        CCWRITE_SNOOP1:
        begin
            if(ccif.ccsnoopaddr[0][0] == 1)
            begin
                if(ccif.ccwrite[0] && ccif.cctrans[0] == 0)
                    n_state = CCWRITE_INV1;
                else if(ccif.ccwrite[0] == 0 && ccif.cctrans[0] == 0)
                    n_state = IDLE;
            end
        end
        CCWRITE_INV0:
        begin
            if(ccif.ccinv[1] == 1 && ccif.ccsnoopaddr[0][1] == 1 && ~ccif.ccsnoopaddr[0][0])
                n_state = CCWRITE_INV0_F;
        end
        CCWRITE_INV0_F:
        begin
            if(~ccif.cctrans[1] && ccif.ccinv[1] == 1 && ccif.ccsnoopaddr[0][1] == 1)
                n_state = IDLE;
        end
        CCWRITE_INV1:
        begin
            if(ccif.ccinv[0] == 1 && ccif.ccsnoopaddr[1][1] == 1 && ~ccif.ccsnoopaddr[1][0])
                n_state = CCWRITE_INV1_F;
        end
        CCWRITE_INV1_F:
        begin
            if(~ccif.cctrans[0] && ccif.ccinv[0] == 1 && ccif.ccsnoopaddr[1][1] == 1)
                n_state = IDLE;
        end
        endcase
    end

    //output logic
    always_comb
    begin
        ccif.iwait      [0] = 1;
        ccif.dwait      [0] = 1;
        ccif.iload      [0] = 0;
        ccif.dload      [0] = 0;
        ccif.ccwait     [0] = 0;
        ccif.ccinv      [0] = 0;
        n_ccsnoopaddr[0] = 0;
        ccif.iwait      [1] = 1;
        ccif.dwait      [1] = 1;
        ccif.iload      [1] = 0;
        ccif.dload      [1] = 0;
        ccif.ccwait     [1] = 0;
        ccif.ccinv      [1] = 0;
        n_ccsnoopaddr[1] = 0;
        n_ramstore       = 0;
        n_ramaddr        = 0;
        n_ramWEN         = 0;
        n_ramREN         = 0;
        //ccif.ramREN         = 0;

        case(state)
        IDLE:
        begin
        end
        IDLE1:
        begin
            if(ccif.dREN[0] && ccif.ccwrite[0] && ccif.cctrans[0] == 1)
                //n_state = SNOOP_RX_0;
                ccif.ccinv[0] = 1;
            else if(ccif.dREN[0] && ~ccif.ccwrite[0] && ccif.cctrans[0] == 1)
                //n_state = SNOOP_R_0;
                ccif.ccinv[0] = 1;
            //go cache1
            else if (ccif.ccwrite[0] && ccif.cctrans[0] == 1)
                //n_state = CCWRITE_SNOOP0;
                ccif.ccinv[0] = 1;
            else if(ccif.dREN[1] && ccif.ccwrite[1] && ccif.cctrans[1] == 1)
                //n_state = SNOOP_RX_1;
                ccif.ccinv[1] = 1;

            else if(ccif.dREN[1] && ~ccif.ccwrite[1] && ccif.cctrans[1] == 1)
                //n_state = SNOOP_R_1;
                ccif.ccinv[1] = 1;
            else if (ccif.ccwrite[1] && ccif.cctrans[1] == 1)
                //n_state = CCWRITE_SNOOP1;
                ccif.ccinv[1] = 1;

            //flush and i access
            if(ccif.dWEN[0])
                //n_state = STORE_W_0;
                ccif.ccinv[0] = 1;

            else if(ccif.dWEN[1])
                //n_state = STORE_W_1;
                ccif.ccinv[1] = 1;

        end
        SNOOP_R_0:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
            n_ccsnoopaddr[1][0] = 1;
            //ccif.ccwait[0] = 1;
            ccif.ccwait[1] = 1;
            ccif.ccinv[0] = 1;//let self inv
        end

        C_C_STORE_R_0:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
            //ccif.ccwait[0] = 1;
            ccif.ccwait[1] = 1;
            //update ram
            if(ccif.cctrans[1])
            begin
                n_ramWEN = 1;
                n_ramaddr = ccif.daddr[1];
                n_ramstore = ccif.dstore[1];
                //cache to cache transfer
                ccif.dload[0] = ccif.dstore[1];
                //ccif.dwait[0] = (ccif.ramstate == ACCESS) ? 0 : 1;
                ccif.dwait[0] = (rams_test) ? 0 : 1;
                //ccif.dwait[1] = (ccif.ramstate == ACCESS) ? 0 : 1;
                ccif.dwait[1] = (rams_test) ? 0 : 1;
            end
            ccif.ccinv[0] = 1;//let self inv

        end

        LOAD_M_R_0:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
            //ccif.ccwait[0] = 1;
            ccif.ccwait[1] = 1;
            //load from memory
            n_ramREN = 1;
            //ccif.ramREN = 1;
            n_ramaddr = ccif.daddr[0];
            ccif.dload[0] = ccif.ramload;
            //ccif.dwait[0] = (ccif.ramstate == ACCESS) ? 0 : 1;
            ccif.dwait[0] = (rams_test) ? 0 : 1;
            //ccif.ccinv[0] = 1;//let self inv
        end

        SNOOP_RX_0:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
            n_ccsnoopaddr[1][0] = 1;
            //ccif.ccwait[0] = 1;
            ccif.ccwait[1] = 1;
            ccif.ccinv[0] = 1;//let self inv
        end

        //INV_HIT_RX_0:
        //begin
            //ccif.ccsnoopaddr[0] = ccif.daddr[0];
            //ccif.ccsnoopaddr[1] = ccif.daddr[0];
            //ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            //invalidate other casches
            //ccif.ccinv[1] = 1;
        //end

        INV_NHIT_RX_0:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
            //ccif.ccwait[0] = 1;
            ccif.ccwait[1] = 1;
            //invalidate other casches
            //n_ccinv[1] = 1;
            ccif.ccinv[1] = 1;
            ccif.ccinv[0] = 1;//let self inv
        end

        C_C_RX_INV0:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
           // ccif.ccwait[0] = 1;// solve final flush issue
           // n_ccsnoopaddr[0][1] = 1;//let lw wait friday
            ccif.ccwait[1] = 1;
            //cache to cache transfer
            ccif.dload[0] = ccif.dstore[1];
            ccif.dwait[0] = ~((ccif.ccsnoopaddr[1] == ccif.daddr[1]) && ccif.cctrans[1]);
            //invalidate other casches
            //n_ccinv[1] = 1;
            ccif.ccinv[1] = 1;
            //ccif.ccinv[0] = 1;//let self inv
        end

        LOAD_M_RX_0:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
           //ccif.ccwait[0] = 1;
            ccif.ccwait[1] = 1;
            //load from memory
            n_ramREN = 1;
            //ccif.ramREN = 1;
            n_ramaddr = ccif.daddr[0];
            ccif.dload[0] = ccif.ramload;
            //ccif.dwait[0] = (ccif.ramstate == ACCESS) ? 0 : 1;
            ccif.dwait[0] = (rams_test) ? 0 : 1;
            //ccif.ccinv[0] = 1;//let self inv
        end

        SNOOP_R_1:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];
            n_ccsnoopaddr[0][0] = 1;
            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            ccif.ccinv[1] = 1;//let self inv
        end

        C_C_STORE_R_1:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];
            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            //update ram
            if(ccif.cctrans[0])
            begin
                n_ramWEN = 1;
                n_ramaddr = ccif.daddr[0]; //original 1 for cache to cache
                n_ramstore = ccif.dstore[0];
                //cache to cache transfer
                ccif.dload[1] = ccif.dstore[0];
                //ccif.dwait[0] = (ccif.ramstate == ACCESS) ? 0 : 1;
                ccif.dwait[0] = (rams_test) ? 0 : 1;
                //ccif.dwait[1] = (ccif.ramstate == ACCESS) ? 0 : 1;
                ccif.dwait[1] = (rams_test) ? 0 : 1;
            end
            ccif.ccinv[1] = 1;//let self inv
        end

        LOAD_M_R_1:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];
            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            //load from memory
            n_ramREN = 1;
            //ccif.ramREN = 1;
            n_ramaddr = ccif.daddr[1];
            ccif.dload[1] = ccif.ramload;
            //ccif.dwait[1] = (ccif.ramstate == ACCESS) ? 0 : 1;
            ccif.dwait[1] = (rams_test) ? 0 : 1;
            //ccif.ccinv[1] = 1;//let self inv
        end

        SNOOP_RX_1:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];
            n_ccsnoopaddr[0][0] = 1;
            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            ccif.ccinv[1] = 1;//let self inv
        end

        //INV_HIT_RX_1:
        //begin
            //ccif.ccsnoopaddr[0] = ccif.daddr[1];
            //ccif.ccsnoopaddr[1] = ccif.daddr[1];
            //ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            //invalidate other casches
            //ccif.ccinv[0] = 1;
        //end

        INV_NHIT_RX_1:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];
            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            //invalidate other casches
            //n_ccinv[0] = 1;
            ccif.ccinv[0] = 1;
            ccif.ccinv[1] = 1;//let self inv
        end

        C_C_RX_INV1:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];

            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;// solve final flush issue
            //n_ccsnoopaddr[1][1] = 1;//let lw wait friday
            //cache to cache transfer
            ccif.dload[1] = ccif.dstore[0];
            ccif.dwait[1] = ~((ccif.ccsnoopaddr[0] == ccif.daddr[0]) && ccif.cctrans[0]);
            //invalidate other casches
            //n_ccinv[0] = 1;
            ccif.ccinv[0] = 1;
            //ccif.ccinv[1] = 1;//let self inv
        end

        LOAD_M_RX_1:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];
            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            //load from memory
            n_ramREN = 1;
            //ccif.ramREN = 1;
            n_ramaddr = ccif.daddr[1];
            ccif.dload[1] = ccif.ramload;
            //ccif.dwait[1] = (ccif.ramstate == ACCESS) ? 0 : 1;
            ccif.dwait[1] = (rams_test) ? 0 : 1;
            //ccif.ccinv[1] = 1;//let self inv
        end

        STORE_W_0:
        begin
            n_ramWEN = ccif.dWEN[0];
            n_ramstore = ccif.dstore[0];
            n_ramaddr = {ccif.daddr[0][31:1], 1'b0};
            ccif.ccwait[1] = 1;
            //if(ccif.ramstate == ACCESS)
            if(rams_test)
            begin
                ccif.dwait[0] = 0;
            end
            ccif.ccinv[0] = 1;//let self inv
        end

        LOAD_M_I_0:
        begin
            n_ramREN = ccif.iREN[0];
            //ccif.ramREN = ccif.iREN[0];
            ccif.iload[0] = ccif.ramload;
            n_ramaddr = ccif.iaddr[0];
            ccif.ccwait[1] = 1;
            ccif.ccwait[0] = 1;//Friday, stop dcache
            if(ccif.ramstate == ACCESS)
            //if(rams_test)
            begin
                ccif.iwait[0] = 0;
            end
        end

        STORE_W_1:
        begin
            n_ramWEN = ccif.dWEN[1];
            n_ramstore = ccif.dstore[1];
            n_ramaddr = {ccif.daddr[1][31:1], 1'b0};
            ccif.ccwait[0] = 1;
            //if(ccif.ramstate == ACCESS)
            if(rams_test)
            begin
                ccif.dwait[1] = 0;
            end
            ccif.ccinv[1] = 1;//let self inv
        end

        LOAD_M_I_1:
        begin
            n_ramREN = ccif.iREN[1];
            //ccif.ramREN = ccif.iREN[1];
            ccif.iload[1] = ccif.ramload;
            n_ramaddr = ccif.iaddr[1];
            ccif.ccwait[0] = 1;
            ccif.ccwait[1] = 1;//Friday, stop dcache
            if(ccif.ramstate == ACCESS)
            //if(rams_test)
            begin
                ccif.iwait[1] = 0;
            end
        end
        CCWRITE_SNOOP0:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
            n_ccsnoopaddr[1][0] = 1;
            n_ccsnoopaddr[1][1] = 1;
            n_ccsnoopaddr[0][1] = 1; //md modify
            n_ccsnoopaddr[0][0] = 1; //friday modify
            ccif.ccwait[1] = 1;
            //ccif.ccwait[0] = 1;
            ccif.ccinv[0] = 1;//let self inv
        end

        CCWRITE_SNOOP1:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];
            n_ccsnoopaddr[0][0] = 1;
            n_ccsnoopaddr[0][1] = 1;
            n_ccsnoopaddr[1][1] = 1;//md modify
            n_ccsnoopaddr[1][0] = 1; //friday modify
            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            ccif.ccinv[1] = 1;//let self inv
        end

        CCWRITE_INV0:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
            ccif.ccwait[1] = 1;
            //ccif.ccwait[0] = 1;
            //n_ccinv[1] = 1;
            ccif.ccinv[1] = 1;
            n_ccsnoopaddr[0][1] = 1;//md modify
            n_ccsnoopaddr[1][1] = 1;//md modify
            ccif.ccinv[0] = 1;//let self inv
        end

        CCWRITE_INV0_F:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[0];
            n_ccsnoopaddr[1] = ccif.daddr[0];
            ccif.ccwait[1] = 1;
            //ccif.ccwait[0] = 1;
            //n_ccinv[1] = 1;
            ccif.ccinv[1] = 1;
            n_ccsnoopaddr[0][1] = 1;//md modify
            n_ccsnoopaddr[1][1] = 1;//md modify
            ccif.ccinv[0] = 1;//let self inv
        end
        CCWRITE_INV1:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];
            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            //n_ccinv[0] = 1;
            ccif.ccinv[0] = 1;
            n_ccsnoopaddr[1][1] = 1;//md modify
            n_ccsnoopaddr[0][1] = 1;//md modify
            ccif.ccinv[1] = 1;//let self inv
        end
        CCWRITE_INV1_F:
        begin
            n_ccsnoopaddr[0] = ccif.daddr[1];
            n_ccsnoopaddr[1] = ccif.daddr[1];
            ccif.ccwait[0] = 1;
            //ccif.ccwait[1] = 1;
            //n_ccinv[0] = 1;
            ccif.ccinv[0] = 1;
            n_ccsnoopaddr[1][1] = 1;//md modify
            n_ccsnoopaddr[0][1] = 1;//md modify
            ccif.ccinv[1] = 1;//let self inv
        end


        endcase
    end
endmodule
