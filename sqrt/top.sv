`include "sqrt.sv"
    
        parameter NBITS = 8, HALF_PRECISION = 5;

module top;        
    
        logic clock, reset;
        logic [NBITS-1:0] A;
        logic [NBITS-1:0]result;
        logic iReady, iValid, oReady, oValid;
        enum logic {S1, S2} state;
        
        initial begin
            clock = 0;
            reset = 1;
            #20 reset = 0;
        end
        
        always #5 clock = !clock;
        
        sqrt #(NBITS) SQRT(.*);
        
        always_ff @(posedge clock)begin
            if(reset)begin
                iValid <= 0;
                oReady <= 0;
                state <= S1;
            end
            else case(state)
                S1: begin
                    A = 20'd6;
                    iValid <= 1;
                    oReady <= 1;    
                    if(iReady)
                        state <= S2;   
                end
                
                S2: begin
                    if(oValid)begin
                        $display("sqrt(%1d) = %d/(1<<%1d)", A, result, HALF_PRECISION);
                        $finish();
                    end
                end
            endcase
        end
        
endmodule
