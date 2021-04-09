
`timescale 1ns/1ns

module Controller(
input clk,                      //clock
input erst,                     //external reset
input done,                     //status signal from the BRWM module
input start,                    //external start command
output reg on_off,              //status signal to the BRWM module
output reg rw,                  //status signal to the BRWM module
output reg camera_trigger       //status signal to the camera
);

parameter [1:0] IDLE = 2'b00, CAMERA_READ = 2'b01, GRAY_WRITE = 2'b10;
reg [1:0] CS, NS;

always @(posedge clk or posedge erst)
begin
 if (erst)
  CS <= IDLE;
 else CS <= NS;
end

always @(start, done)
begin
 case(CS)
 IDLE: begin
        on_off = 1'b0;
        rw = 1'bz;
        camera_trigger = 1'b0;
        if (start == 1'b1)
         NS = CAMERA_READ;
        else NS = IDLE;
       end
 CAMERA_READ: begin
               camera_trigger = 1'b1;
               on_off = 1'b1;
               rw = 1'b1;
               if (done == 1'b1)
                NS = GRAY_WRITE;
               else NS = CAMERA_READ;
              end
 GRAY_WRITE: begin
               camera_trigger = 1'b0;
               on_off = 1'b1;
               rw = 1'b0;
               if (done == 1'b1)
                NS = IDLE;
               else NS = GRAY_WRITE;
             end
 default: NS = IDLE;
 endcase
end

endmodule