/*
Working of this module:
It uses two reg matrices, one to store the image of resolution n x m pixels in one frame and the other to select the required pixels for the convolution. 
Here one pixel is considered to be of 1 byte wide. To do this, the entire operation is divided into 3 subtasks:-
a) storage of the n x m pixels
b) selecting the 9 bytes needed to perform the sobel filter convolution
c) performing the 3 x 3 sobel convolution
This cycle repeats for every subsequent frames. A FSM with 4 states is defined to sequence these subtasks correctly.
*/
module sobel_filter(
    input [7:0] Din,
    input data_valid, clk,
    input rst,  //external active high asynchronous reset
    output fill_now,    //status signal to indicate whether the first reg matrix is empty or not
    output [15:0] Dout  
);

reg [15:0] result;

parameter N = 720, M = 1280;    //resolution of the image

//reg matrix to store the image pixels in a frame of operation
reg [7:0] storage[0:N-1][0:M-1];     
//3 x 3 reg matrix to house the 9 bytes for the sobel convolution
reg [7:0] image_kernal[0:2][0:2];

integer r, c, i, j;

parameter IDLE = 2'b00, STORE = 2'b01, FIX = 2'b10, CONVOLUTE = 2'b11;
reg [1:0] PS, NS;

//sequential logic
always @(posedge clk or posedge rst)
begin
 if (rst) 
  PS <= IDLE;    //every value is reset to its default value in IDLE
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
          NS <= FIX;    //fill the last byte of the matrix and go to next state
         end
         else if(c == M-1)
          begin
           storage[r][c] <= Din;
           c <= 0;
           r <= r+1;
           NS <= STORE; //fill the last byte of current row and remain in this state
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
       NS <= CONVOLUTE; //fill the image kernal with that of storage. The starting position is specified by i and j.
      end
 CONVOLUTE: begin
             if((i == N-3) && (j == M-3))
             begin
              result <= image_kernal[0][0] + (2*image_kernal[0][1]) + image_kernal[0][2] - image_kernal[2][0] - (2*image_kernal[2][1]) - image_kernal[2][2];
              NS <= IDLE; //perform the last convolution in the current frame and go to IDLE
             end
             else if(c == M-3)
              begin
               result <= image_kernal[0][0] + (2*image_kernal[0][1]) + image_kernal[0][2] - image_kernal[2][0] - (2*image_kernal[2][1]) - image_kernal[2][2];
               j <= 0;
               i <= i+1;
               NS <= FIX; //perform the last convolution in the current horizontal direction. Move one row down and go to FIX to take the next 9 pixels.
              end
             else 
              begin
               result <= image_kernal[0][0] + (2*image_kernal[0][1]) + image_kernal[0][2] - image_kernal[2][0] - (2*image_kernal[2][1]) - image_kernal[2][2];
               j <= j+1;
               NS <= FIX; //perform the covolution. Move one column right and go to FIX to take the next 9 pixels.
              end
            end
 default: PS <= IDLE;
 endcase
end 

assign fill_now = ((PS==FIX) || (PS==CONVOLUTE)) ? 1'b0 : 1'b1;
//storage is full when PS is in FIX nd CONVOLUTE states.
assign Dout = (PS==CONVOLUTE) ? result : 16'hzzzz;
//output data is available when PS is in CONVOLUTE state.

endmodule 
