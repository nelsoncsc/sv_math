`include "SQRTLOG.sv"

// op = 0 ==> data_out = sqrt(data_in)
// op = 1 ==> data_out = log2(data_in)
// op = 2 ==> data_out = log10(data_in)
// op = 3 ==> data_out = ln(data_in)
       
module top;        
    
        logic clock, reset, done;
        logic [1:0] op;
        logic [NBITS-1:0] X, Y;
        
        initial begin
            clock = 0;
            reset = 1;
            #20 reset = 0;
            //X = 3216; //pi
            X = 2783;  //e
        end
        
        always #5 clock = !clock;
        always_ff @(posedge clock)begin
          if(done)begin
            $display("%d", Y);
            $finish();
          end
        end 
                         
  SQRTLOG sl(.clock(clock), .reset(reset), .done(done), .op(2'd2), .data_in(X), .data_out(Y)); 
            
endmodule
