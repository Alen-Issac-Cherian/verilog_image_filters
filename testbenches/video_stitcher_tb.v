
`timescale 1ns/1ns

module video_stitcher_tb;

reg clk, erst, pause, start, clear;
wire camera_enable, data_valid, on_off, rw, done;
wire [7:0] BRWM_data, camera_data;

Controller control (clk, erst, done, start, on_off, rw, camera_enable);
camera interface (clk, camera_enable, data_valid, camera_data);
BRWM MUT (clk, on_off, rw, clear, pause, camera_data, BRWM_data, done);

initial 
begin
 $dumpfile("video_stitcher_tb.vcd");
 $dumpvars(0, video_stitcher_tb);

 erst = 1;
 pause = 0;
 clear = 0;
 start = 0;
 #150;
 erst = 0;
 start = 1;
 #20;
 start = 0;
 #130;
 #150;
 #150
 $finish;
end

always 
begin
 clk = 1'b0;
 #1;
 clk = 1'b1;
 #1;
end

endmodule