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

module memory_control (
    input CLK, nRST,
    cache_control_if.cc ccif
);
    // type import
    import cpu_types_pkg::*;

    // number of cpus for cc
    parameter CPUS = 1;

    logic [2:0] stat; // execute which unit 0 for d and 1 for i
    assign stat = {ccif.iREN[0], ccif.dREN[0], ccif.dWEN[0]};
    //assign ccif.iload = (ccif.iwait == 0 && ccif.iREN[0] == 1) ? ccif.ramload : 0;
    always_comb
    begin
        //ccif.iload = 0;
        ccif.dload = 0;
        ccif.ramstore = 0;
        ccif.ramaddr = 0;
        ccif.ramWEN = 0;
        ccif.ramREN = 0;
        ccif.iwait = 1;
        ccif.dwait = 1;
        //if (ccif.ramstate == ACCESS && ccif.iREN[0])
        //begin
          //  ccif.iload = ccif.ramload;
        //end
        //if (ccif.ramstate == ACCESS && ccif.dREN[0])
        //begin
          //  ccif.dload = ccif.ramload;
        //end
        //if (ccif.iwait == 0 && ccif.iREN[0] == 1)
        //begin
            //ccif.iload = ccif.ramload;
        //end
        case (stat)
            3'b100: begin
                //if (ccif.iwait == 0)
                //begin
                //    ccif.iload = ccif.ramload;
                //end
                ccif.iload = ccif.ramload;
                ccif.ramaddr = ccif.iaddr;
                ccif.ramREN = 1;
                ccif.iwait = ccif.ramstate == ACCESS ? 0 : 1;
            end
/////////////////do dREN
            3'b110: begin
                ccif.ramREN = 1;
                ccif.dload = ccif.ramload;
                ccif.ramaddr = ccif.daddr;
                ccif.dwait = ccif.ramstate == ACCESS ? 0 : 1;
            end
            3'b010: begin
                ccif.ramREN = 1;
                ccif.dload = ccif.ramload;
                ccif.ramaddr = ccif.daddr;
                ccif.dwait = ccif.ramstate == ACCESS ? 0 : 1;

            end
/////////////////do dWEN
            3'b101: begin
                ccif.ramWEN = 1;
                ccif.ramaddr = ccif.daddr;
                ccif.ramstore = ccif.dstore;
                ccif.dwait = ccif.ramstate == ACCESS ? 0 : 1;
            end
            3'b001: begin
                ccif.ramWEN = 1;
                ccif.ramaddr = ccif.daddr;
                ccif.ramstore = ccif.dstore;
                ccif.dwait = ccif.ramstate == ACCESS ? 0 : 1;
            end
        endcase

    end


endmodule
