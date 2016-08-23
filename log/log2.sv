module LOG #(parameter M=4,
                       N=10) //1.M.N (1 bit de sinal)
            (output logic [M+N: 0] logNumber,
             output logic iReady, oValid, 
             input logic [M+N: 0] number, 
             input logic reset, clock, oReady, iValid
             );
    
    logic signed [M+N: 0] floorNumber, index;
    logic [M+M+N+N:0] x, a, b; //a and b will be used for Peasant Multiplication
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
                        x <= number; //Soon will be scaled
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
                        index <= index<<<N; //Let index in fixed point 1.M.N format
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
                        x <= x>>N; //X is defined with double precision, requiring this shift
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
endmodule: LOG
