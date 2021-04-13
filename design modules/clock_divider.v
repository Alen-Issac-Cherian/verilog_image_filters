
`timescale 1ns/1ns

module clock_divider(
 input CLOCK_50,
 input erst,
 output clk,
 output done
);

integer counter;

always @(posedge CLOCK_50) 
begin
 if (!erst || counter >= 49999999)
  counter <= 0;
 else counter <= counter + 1;
end


assign clk = (counter <= 24999999) ? 1'b0 : 1'b1;
assign done = 0;

endmodule
