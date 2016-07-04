`include "divider.sv"
    
        parameter NBITS = 8;

module top;        
    
        logic clock, reset;
        logic [NBITS-1:0] A,B;
        logic [NBITS-1:0]quotient, remainder;
        logic iReady, iValid, oReady, oValid;
        
        enum logic {S1, S2} state;
        
        initial begin
            clock = 0;
            reset = 1;
            #20 reset = 0;
        end
        
        always #5 clock = !clock;
        
        divider #(NBITS) div(.*);
        
        always_ff @(posedge clock)begin
            if(reset)begin
                iValid <= 0;
                oReady <= 0;
                state <= S1;
            end
            else case(state)
                S1: begin
                    A = 8'd123;
                    B = 8'd11;
                    iValid <= 1;
                    oReady <= 1;    
                    if(iReady)
                        state <= S2;   
                end
                
                S2: begin
                    if(oValid)begin
                        $display(A,B,quotient, remainder);
                        $finish();
                    end
                end
            endcase
        end
        
endmodule
