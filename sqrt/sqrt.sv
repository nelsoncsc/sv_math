module sqrt #(parameter NBITS = 8, PRECISION = 10)
                (input logic [NBITS-1:0] A,
                 input logic clock, reset, oReady, iValid,
                 output logic iReady, oValid,
                 output logic [NBITS-1:0]result);
    
    enum logic [1:0] {INIT, SET, CALC, SEND} state; 
    logic [NBITS+NBITS-1:0] A_aux, Y, P;
    logic [$clog2(NBITS):0] m;
                           
    always_ff @(posedge clock)begin
        if(reset)begin
            A_aux <= '0;
            result <= '0;
            m <= NBITS-1;
            state <= INIT;
            iReady <= 0;
            oValid <= 0;
        end
         
        else begin
            case(state)
                INIT: begin
                        iReady <= 1;
                        oValid <= 0;
                        A_aux <= A<<<PRECISION;
                        Y <= '0;
                        P <= '0;
                        m <= NBITS-1;
                        state <= SET;       
                end
                
                SET: begin
                       if(m < NBITS)begin
                         Y <= ((P<<<(m+1)) + (1 <<< (m+m)));
                         state <= CALC;
                       end
                       else begin
                         oValid <= 1;
                         state <= SEND;
                       end
                end
                CALC: begin
                    if(Y < A_aux || Y == A_aux)begin
                        A_aux <= A_aux - Y;
                        P <= P + (1 <<< m);
                        result[m] <= 1;
                    end  
                    else result[m] <= 0;
                        m <= m-1;
                        state <= SET;
                end
                
                SEND: begin
                    if(oReady)begin
                        result <= result >>>(PRECISION-1);
                        oValid <= 0;
                        state <= INIT;
                    end
                end
            endcase
        end
    end
                          
endmodule
