module step_motor#(
	parameter	cnt_speed = 100000
)(
	input		clk,
	input		rst_n,
	
	output reg [3:0] out
);

reg [21:0] counter = 22'd0;
reg [1:0] count = 2'd0;
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    counter = 22'd0;
	 count = 2'd0;
  end 
  else if(counter == cnt_speed) begin
    counter <= 0;
    count <= count + 1;
  end else begin
    counter <= counter + 1;
  end
end

always@(*) begin  //正转
  case(count)
		3'd0: out <= 4'b1000;
		3'd1: out <= 4'b0100;
		3'd2: out <= 4'b0010;
		3'd3: out <= 4'b0001;
		//3'd4: out <= 4'b0001;
		//3'd5: out <= 4'b0010;
		//3'd6: out <= 4'b0100;
		//3'd7: out <= 4'b1000;
	default:out <= 4'b1000;
  endcase
end


endmodule
