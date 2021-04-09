/*
Working of this module:
It uses two reg arrays, one to store the image of resolution n x m pixels in one frame and the other to select the required pixels for the convolution. 
Here one pixel is considered to be of 1 byte wide. To do this, the entire operation is divided into 3 subtasks:-
a) storage of the n x m pixels
b) selecting the 9 bytes needed to perform the sobel filter convolution
c) performing the 3 x 3 sobel convolution
This cycle repeats for every subsequent frames. A FSM with 4 states is defined to sequence these subtasks correctly.
*/

`timescale 1ns/1ns

module sobel_filter(
    input [7:0] Din,
    input data_valid, rst, clk,
    output fill_now,    //status signal to indicate whether the first reg matrix is empty or not
    output reg [1:0] state, //to know in which state the FSM is in
    output [15:0] Dout
);

reg [15:0] result;

parameter N = 720, M = 120; //resolution of the image

reg [7:0] storage[0:N*M-1]; //reg array to store the image pixels in a frame of operation
reg [7:0] image_kernal[0:8];    //reg array to house the 9 bytes for the sobel convolution

integer count, i, j, k;

parameter IDLE = 2'b00, STORE = 2'b01, FIX = 2'b10, CONVOLUTE = 2'b11;
reg [1:0] PS, NS;

//sequential logic
always @(posedge clk or posedge rst)
begin
 if (rst) 
  PS <= IDLE;    //every value is reset to its default value in IDLE
 else PS <= NS;    
end

always @(posedge clk) 
begin
 if(PS == STORE)
 begin
  storage[i] <= Din;    //to store the incoming pixel byte into the next position in the storage array
  i <= (i == 24) ? 0 : i + 1;
 end
end

//combinatorial logic
always @(Din,data_valid,i,count,k,PS)
begin
 case (PS)
 IDLE: begin
        state = 2'b00;

        result = 16'h0000;
        count = 0;  //to count the number of convolutions in a frame
        i = 0;  
        j = 0;
        k = 0;
        
        if(data_valid)
         NS = STORE;
        else NS = IDLE;
       end
 STORE: begin
         state = 2'b01;
         NS = (i == 24) ? FIX : STORE;  
        end
 FIX: begin
       state = 2'b10;
       //to place the the required bytes in the kernal for convolution
       image_kernal[0] = storage[j];
       image_kernal[1] = storage[j+1];
       image_kernal[2] = storage[j+2];
       image_kernal[3] = storage[j+5];
       image_kernal[4] = storage[j+6];
       image_kernal[5] = storage[j+7];
       image_kernal[6] = storage[j+10];
       image_kernal[7] = storage[j+11];
       image_kernal[8] = storage[j+12];
       
       NS = CONVOLUTE;
      end
 CONVOLUTE: begin
             state = 2'b11;
             result = image_kernal[0] + 2*image_kernal[1] + image_kernal[2] - image_kernal[6] - 2*image_kernal[7] - image_kernal[8];
             count = count + 1; 
             if(count != (N-2)*(M-2))
             begin 
              if(k != (M-2))
              begin
               j = j + 1;
               k = k + 1;
               NS = FIX;
              end
              else 
              begin
               j = j + 3;
               k = 0;
               NS = FIX;
              end
             end
             else NS = IDLE;
            end
 
 endcase
end 

assign fill_now = ((PS==FIX) || (PS==CONVOLUTE)) ? 1'b0 : 1'b1; //storage is full when PS is in FIX and CONVOLUTE states.
assign Dout = (PS==CONVOLUTE) ? result : 16'hzzzz;  //output data is available when PS is in CONVOLUTE state.

endmodule 
