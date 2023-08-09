module dist_calculate(
	input				clk,
	input				rst_n,
	
	input				rx_data_en,
	input	[7:0]		rx_data,
	
	output reg [15:0]	data,
	output        	tx_en,                  
   output   [7:0] tx_data
);

reg give_en = 1'b0;

//reg [7:0] data_byte0_h;
//reg [7:0] data_byte0_l;
//reg [7:0] data_byte0_h;
//reg [7:0] data_byte0_l;
//reg [7:0] data_byte0_h;
//reg [7:0] data_byte0_l;
reg [3:0] state,next_state;
reg [2:0] times=3'd0;
parameter	header1 = 4'b0000,
				header2 = 4'b0001,
				addr1 = 4'b0010,
				addr2 = 4'b0011,
				function1 = 4'b0100,
				function2 = 4'b0101,
				function3 = 4'b0110,
				length = 4'b0111,
				receive_data = 4'b1000;
				//receive_data_l = 4'b1001,

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		//next_state <= 4'b0;
		state <= 4'b0;
		data <= 16'd0;
	end
	else if(rx_data_en) begin
		case(state)
				header1:begin
					if(rx_data==8'h55)
						state <= header2;
				end
				header2:begin
					if(rx_data==8'h0b)
						state <= addr1;
				end
				addr1:begin
					if(rx_data==8'h00)
						state <= addr2;
				end
				addr2:begin
					if(rx_data==8'h01)
						state <= function1;
				end
				function1:begin
					if(rx_data==8'h00)
						state <= function2;
				end
				function2:begin
					if(rx_data==8'h00)
						state <= function3;
				end
				function3:begin
					if(rx_data==8'h05)
						state <= length;
				end
				length:begin
					if(rx_data==8'h02) begin
						state <= receive_data;
						//times <= times + 1'b1;
					end
				end
				receive_data:begin
					if(times==3'd0) begin
						times <= times + 1'b1;
						data[15:8] <= rx_data;
						//data[15:8] <= 8'haa;
						state <= receive_data;
					end
					else if(times==3'd1) begin
						times <= times + 1'b1;
						data[7:0]  <= rx_data;
						//data[15:8] <= rx_data;
						//data[7:0]  <= 8'h55;
						state <= header1;
					end
					/*
					else if(times==3'd2) begin
						times <= times + 1'b1;
						//data[7:0]  <= rx_data;
						data[15:8] <= rx_data;
						//data[7:0]  <= 8'h55;
						//state <= header1;
					end
					else if(times==3'd3) begin
						times <= 3'd0;
						data[7:0]  <= rx_data;
						state <= header1;
					end
					*/
				end

				default : ;
			endcase
		end
end
/*
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state <= 4'b0;
	else
		state <= next_state;
end
*/
//assign tx_en = give_en;
//assign tx_data = (times==3'd0)? data[15:8] : data[7:0];

endmodule
