

module sobel_filter(
    input [7:0] Din,
    input data_valid, rst, clk,
    output fill_now,
    output [15:0] Dout
);

reg [15:0] result;

parameter N = 720, M = 1280;

reg [7:0] storage[0:N-1][0:M-1];
reg [7:0] image_kernal[0:2][0:2];

integer r, c, i, j;

parameter IDLE = 2'b00, STORE = 2'b01, FIX = 2'b10, CONVOLUTE = 2'b11;
reg [1:0] PS, NS;

//sequential logic
always @(posedge clk or posedge rst)
begin
 if (rst) 
  PS <= IDLE;    
 else PS <= NS;    
end

//combinatorial logic
always @(*)
begin
 case (PS)
 IDLE: begin
        for(r = 0, r < N, r = r+1) 
        begin
         for(c = 0, c < M, c = c+1) 
          storage[r][c] <= 8'h00;
        end

        for(r = 0, r < 3, r = r+1) 
        begin
         for(c = 0, c < 3, c = c+1) 
          image_kernal[r][c] <= 8'h00;
        end

        result <= 16'h0000;
        r <= 0;
        c <= 0;
        i <= 0;
        j <= 0;

        if(data_valid)
         NS <= STORE;
        else NS <= IDLE;
       end
 STORE: begin
         if((r == N-1) && (c == M-1))
         begin
          storage[r][c] <= Din;
          NS <= FIX;
         end
         else if(c == M-1)
          begin
           storage[r][c] <= Din;
           c <= 0;
           r <= r+1;
           NS <= STORE;
          end
         else 
         begin
          storage[r][c] <= Din;
          c <= c+1;
          NS <= STORE;
         end
        end
 FIX: begin
       for(r = i, r < i+3, r = r+1) 
        begin
         for(c = j, c < j+3, c = c+1) 
          image_kernal[r][c] <= storage[r][c];
        end
       NS <= CONVOLUTE;
      end
 CONVOLUTE: begin
             if((i == N-3) && (j == M-3))
             begin
              result <= image_kernal[0][0] + (2*image_kernal[0][1]) + image_kernal[0][2] - image_kernal[2][0] - (2*image_kernal[2][1]) - image_kernal[2][2];
              NS <= IDLE;
             end
             else if(c == M-3)
              begin
               result <= image_kernal[0][0] + (2*image_kernal[0][1]) + image_kernal[0][2] - image_kernal[2][0] - (2*image_kernal[2][1]) - image_kernal[2][2];
               j <= 0;
               i <= i+1;
               NS <= FIX;
              end
             else 
              begin
               result <= image_kernal[0][0] + (2*image_kernal[0][1]) + image_kernal[0][2] - image_kernal[2][0] - (2*image_kernal[2][1]) - image_kernal[2][2];
               j <= j+1;
               NS <= FIX;
              end
            end
 default: PS <= IDLE;
 endcase
end 

assign fill_now = ((PS==FIX) || (PS==CONVOLUTE)) ? 1'b0 : 1'b1;
assign Dout = (PS==CONVOLUTE) ? result : 16'hzzzz;

endmodule 