module peasant #(parameter NBITS = 20)
                (input logic [NBITS-1:0] A,B,
                 input logic clock, reset, oReady, iValid,
                 output logic iReady, oValid,
                 output logic [NBITS+NBITS-1:0]result);
    
    enum logic [1:0] {INIT, CALC, SEND} state; 
    logic [NBITS+NBITS-1:0] A_aux, B_aux;
                           
    always_ff @(posedge clock)begin
        if(reset)begin
            A_aux <= '0;
            B_aux <= '0;
            result <= '0;
            state <= INIT;
            iReady <= 0;
            oValid <= 0;
        end
         
        else begin
            case(state)
                INIT: begin
                        iReady <= 1;
                        oValid <= 0;
                        A_aux <= A;
                        B_aux <= B;
                        state <= CALC;        
                end
                
                CALC: begin
                    if(A_aux >= 1)begin
                        A_aux <= (A_aux >>> 1);
                        B_aux <= (B_aux <<< 1);
                        result <= result + (A_aux[0] ? B_aux : 0);
                    end  
                    else begin
                        state <= SEND;
                        oValid <= 1;
                    end
                end
                
                SEND: begin
                    if(oReady)begin
                        oValid <= 0;
                        state <= INIT;
                    end
                    else state <= SEND;
                end
            endcase
        end
    end
                          
endmodule
