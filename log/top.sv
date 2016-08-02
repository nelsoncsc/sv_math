`include "log2.sv"

parameter M = 4;
parameter N = 10;

module top;
    logic clock;
    logic reset;
    logic iReady, iValid, oReady, oValid;
    
    logic signed [M+N: 0] number, logNumber;
    
    enum logic {S1,S2} state;
    
    initial begin
        clock = 0;
        reset = 1;
        #22 reset = 0;
    end

    always #5 clock = !clock;

    LOG#(M,N) myLog(.*);
    
    always_ff @(posedge clock) begin
        if(reset) begin
            iValid <= 0;
            state <= S1;
            oReady <= 0;
        end
        else case(state)
            S1: begin
                number <= 15'b00011_0010010000;
                iValid <= 1;
                if(iReady)
                    state <= S2;
                    oReady <= 1;
            end
            S2: 
                if(oValid) begin
                    if(logNumber[M+N])
                        $display("%b", (~logNumber+15'd1));
                    else
                        $display("%b", logNumber);
                        
                    $finish();
                end
        endcase
    end
endmodule
