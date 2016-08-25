parameter NBITS = 20;
parameter M = 10;
parameter N = 10;

module sqrt #(parameter NBITS = 20, PRECISION = 20)
                (input logic [NBITS-1:0] A,
                 input logic clock, reset, oReady, iValid,
                 output logic iReady, oValid,
                 output logic [NBITS-1:0]result);
    
    enum logic [1:0] {INIT, SET, CALC, SEND} state; 
    logic [NBITS+NBITS-1:0] A_aux, Y, P;
    logic [6:0] m;
                           
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


module LOG2 #(parameter M=10,
                       N=10) 
            (output logic [M+N: 0] logNumber,
             output logic iReady, oValid, 
             input logic [M+N-1: 0] number, 
             input logic reset, clock, oReady, iValid
             );
    
    logic signed [M+N-1: 0] floorNumber, index;
    logic [M+M+N+N-1:0] x, a, b; 
    logic [5:0] count;
    enum logic [2:0] {INIT,WAIT_AND_PREPARE,SCALE,PEASANT_PREP,PEASANT,CALC,SEND} state;
    
    always_ff @(posedge clock)
        if(reset) begin
            iReady <= 0;
            logNumber <= 'x;
            oValid <= 0;
            state <= INIT;
        end
        else case(state)
                INIT: begin
                    logNumber <= '0;
                    iReady <= 1;
                    oValid <= 0;
                    count <= N-1;
                    index <= 0;
                    state <= WAIT_AND_PREPARE;
                end
                
                WAIT_AND_PREPARE: begin
                    if(iValid) begin
                        iReady <= 0;
                        x <= number; 
                        state <= SCALE;
                    end
                    else begin
                        state <= WAIT_AND_PREPARE;
                    end
                end
                
                SCALE: begin
                    if((x>>N) > 1) begin
                        x <= x >> 1;
                        index <= index+1;
                    end
                    else if(!(x>>N)) begin
                        x <= x << 1;
                        index <= index-1;
                    end
                    else begin
                        index <= index<<<N; 
                        state <= PEASANT_PREP;                     
                    end
                end
                
                PEASANT_PREP: begin
                    a <= x;
                    b <= x;
                    x <= 0;
                    state <= PEASANT;
                end
                
                PEASANT: begin
                    if(a>=1) begin
                        x <= (a[0])?(x+b):x;
                        a <= a >> 1;
                        b <= b << 1;
                    end
                    else begin
                        x <= x>>N; 
                        state <= CALC;
                    end
                end
                
                CALC: begin
                  if(count<=N-1) begin
                        if((x>>N) >= 2) begin
                            logNumber[count] <= 1;
                            x <= x>>1;
                        end
                        else logNumber[count] <= 0;
                        
                        count <= count-1;
                        state <= PEASANT_PREP;
                    end
                    else begin 
                        state <= SEND;
                        logNumber <= index+logNumber;
                        oValid <= 1;
                    end
                end
                
                SEND: begin
                    if(oReady) begin
                        oValid <= 0;
                        state <= INIT;
                    end
                    else state <= SEND;
                end
        endcase
endmodule: LOG2

module SQRTLOG(input logic clock, reset,
               input logic [1:0] op,
                 input logic [NBITS-1:0] data_in,
                 output logic done,
                 output logic [NBITS-1:0] data_out);
                 
        logic [NBITS-1:0] A;
        logic [NBITS-1:0]result;
        logic iReady, iValid, oReady, oValid;
        logic iReady2, iValid2, oReady2, oValid2;
        
        enum logic [1:0]{S1, S2, S3} state;
        
  logic signed [M+N: 0] number, logNumber, base;
        
        sqrt #(NBITS) SQRT(.clock(clock), .reset(reset), .iReady(iReady), .iValid(iValid), 
                           .oReady(oReady), .oValid(oValid), .A(data_in), .result(result));
        
        LOG2#(M,N) myLog(.clock(clock), .reset(reset), .iReady(iReady2), .iValid(iValid2), 
                          .oReady(oReady2), .oValid(oValid2), .number(data_in), .logNumber(logNumber));
         
         always_ff @(posedge clock)begin
           if(reset)begin
             iValid <= 0;
             oReady <= 0;
             iValid2 <= 0;
             oReady2 <= 0;
             done <= 0;
             state <= S1;
           end
           else case(state)
             S1: begin
               case(op)
                 0: begin
                   A = data_in;
                   iValid <= 1;
                   oReady <= 1;    
                   if(iReady)
                     state <= S2;
                 end
                 
                 1: begin
                   number = data_in;
                   iValid2 <= 1;
                   oReady2 <= 1;    
                   if(iReady2)
                     state <= S2;
                 end
                 
                 2: begin
                   number = data_in;
                   iValid2 <= 1;
                   oReady2 <= 1;    
                   if(iReady2)
                     state <= S2;
                 end
                 
                 3: begin
                   number = data_in;
                   iValid2 <= 1;
                   oReady2 <= 1;    
                   if(iReady2)
                     state <= S2;
                 end
               endcase
             end
             
             S2: begin
               case(op)
                 0: begin
                   if(oValid)begin
                     data_out <= (result>>5);
                     state <= S3;
                   end
                 end
                 
                 1: begin
                   if(oValid2)begin
                     data_out <= logNumber;
                     state <= S3;
                   end
                 end
                 
                 2: begin
                   if(oValid2)begin
                     data_out <= ((308*logNumber)>>10);
                     state <= S3;
                   end
                 end
                 
                 3: begin
                   if(oValid2)begin
                     data_out <= ((710*logNumber)>>10);
                     state <= S3;
                   end
                 end
               endcase
             end
             
             S3: begin
               done <= 1;
             end
           endcase
         end
endmodule                          

