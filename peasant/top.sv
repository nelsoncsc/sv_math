`include "peasant.sv"
    
        parameter NBITS = 8;

module top;        
    
        logic clock, reset;
        logic [NBITS-1:0] A,B;
        logic [NBITS+NBITS-1:0]result;
        logic iReady, iValid, oReady, oValid;
        
        enum logic {S1, S2} state;
        
        initial begin
            clock = 0;
            reset = 1;
            #20 reset = 0;
        end
        
        always #5 clock = !clock;
        
        peasant #(NBITS) mult(.*);
        
        always_ff @(posedge clock)begin
            if(reset)begin
                iValid <= 0;
                oReady <= 0;
                state <= S1;
            end
            else case(state)
                S1: begin
                    A = 8'd12;
                    B = 8'd11;
                    iValid <= 1;
                    oReady <= 1;    
                    if(iReady)
                        state <= S2;   
                end
                
                S2: begin
                    if(oValid)begin
                        $display(A,B,result);
                        $finish();
                    end
                end
            endcase
        end
        
endmodule
