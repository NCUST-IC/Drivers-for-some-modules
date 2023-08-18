module myram(
	input		clk,
	input	[9:0] write_addr,
	input	[7:0]	write_data,
	
	input [9:0]	read_addr,
	output reg [7:0]	read_data
);

//存储128*8页 个byte（8bit）
reg	[7:0]	memory	[1023:0];

initial $readmemh("xin.txt", memory);

always@(posedge clk) 	
	memory[write_addr] <= write_data;
always@(posedge clk)  	
	read_data<= memory[read_addr];


endmodule
