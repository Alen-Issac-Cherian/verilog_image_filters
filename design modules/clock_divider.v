
module clock_divider(
 input CLOCK_50,
 input erst,
 output clk
);

integer counter;

always @(posedge CLOCK_50 or posedge erst) 
begin
 if (erst)
  counter <= 0;
 else counter <= counter + 1;
 if (counter >= 4,99,99,999)
  counter <= 0;
end

assign clk = (counter <= 24999999) ? 1'b0 : 1'b1;

endmodule