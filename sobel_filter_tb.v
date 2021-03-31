
`timescale 1ns/1ns

module sobel_filter_tb;

reg [7:0] Din;
reg rst, clk, data_valid;
wire fill_now;
wire [1:0] state;
wire [15:0] Dout;

sobel_filter UUT (Din, data_valid, rst, clk, fill_now, state, Dout);

initial 
begin
 $dumpfile("sobel_filter_tb.vcd");
 $dumpvars(0, sobel_filter_tb);

 rst = 1;
 Din = 8'hf0;
 data_valid = 0;
 #350;
 rst = 0;
 data_valid = 1;
 #10000000;
 $finish;
end

always 
begin
 clk = 1'b0;
 #10;
 clk = 1'b1;
 #10;
end

endmodule 
