module divider #(parameter NBITS = 8)
                (input logic [NBITS-1:0] A,B,
                 input logic clock, reset, oReady, iValid,
                 output logic iReady, oValid,
                 output logic [NBITS-1:0]quotient, remainder);
    
    enum logic [1:0] {INIT, CALC, SEND} state; 
    logic [(NBITS<<1)-1:0] A_aux, B_aux;
    logic [3:0]i;
                           
    always_ff @(posedge clock)begin
        if(reset)begin
            i <= 0;
            A_aux <= '0;
            B_aux <= '0;
            quotient <= '0;
            state <= INIT;
            iReady <= 0;
            oValid <= 0;
        end
         
        else begin
            case(state)
                INIT: begin
                        i <= NBITS-1; 
                        iReady <= 1;
                        oValid <= 0;
                        A_aux <= A;
                        B_aux <= B;
                        state <= CALC;        
                end
                
                CALC: begin
                    if(i < NBITS)begin
                      if(A_aux >= (B_aux<<i))begin
                        A_aux <= A_aux-(B_aux<<i);
                        quotient[i] <= 1;
                      end
                      else quotient[i] <= 0;
                      
                      $display(i, quotient, A_aux);
                      i <= i-1;
                    end
                     
                    else begin
                        remainder <= A_aux;
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
