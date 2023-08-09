module reg_7Byte(
	input				clk,
	input				rst_n,
	
	input				flag_start,
	input            	tx_busy, 
	
    output reg       	tx_en,                  
    output reg  [7:0] 	tx_data
);

//start and end signs
reg		start_en;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		start_en <= 1'b0;
	else if(cnt_data == 5'd11)
		start_en <= 1'b0;
	else if(flag_start)
		start_en <= 1'b1;
	else
		start_en <= start_en;
end


//delay pos_Byte
reg [15:0] cnt_give_pos;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt_give_pos <= 16'd0;
	else 
		if(start_en) begin
			if(cnt_give_pos == 16'd4900)
				cnt_give_pos <= 16'd0;
			else
				cnt_give_pos <= cnt_give_pos + 1'b1;
		end
		
end

reg	give_en;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		give_en	<= 1'b0;
	else if(cnt_give_pos == 16'd4900)
		give_en <= 1'b1;
	else 
		give_en <= 1'b0;
end
//pos_Byte and cnt of Byte_datas
reg [4:0]	cnt_data;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt_data <= 4'b0;
	end
	else 
		if(start_en)begin
			if(give_en)begin
				cnt_data <= cnt_data + 1'b1;
			end
			else begin
				cnt_data <= cnt_data;
			end
		end
		else begin
			cnt_data <= 4'd0;
		end
end

reg [7:0] data_r;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		data_r <= 8'b0;
	end
	else case(cnt_data)
			4'd0  	: data_r <= 8'h51;	//标志头
			4'd1		: data_r <= 8'h0B;	//传感器类型
			4'd2    	: data_r <= 8'h00;	//传感器地址
			4'd3		: data_r <= 8'h01;
			4'd4		: data_r <= 8'h00;	//读0x00  写0x01
			4'd5		: data_r <= 8'h05;	//功能码
			4'd6  	: data_r <= 8'h02;  	//数据长度
			4'd7  	: data_r <= 8'h00;	//校验码
			4'd8  	: data_r <= 8'h64;
			4'd9		: data_r <= 8'h0D;	//发送新行
			4'd10		: data_r <= 8'h0A;
			default : ;
	endcase
end


//判断接收完成信号，并在串口发送模块空闲时给出发送使能信号
reg tx_ready;
always @(posedge clk or negedge rst_n) begin         
    if (!rst_n) begin
        tx_ready  <= 1'b0; 
        tx_en   <= 1'b0;
        tx_data <= 8'd0;
    end                                                      
    else begin                                               
        if(give_en)begin                 
            tx_ready  <= 1'b1;                  //准备启动发送过程
            tx_en   <= 1'b0;
            tx_data <= data_r;             //寄存串口接收的数据
        end
        else if(tx_ready && (~tx_busy)) begin   //检测串口发送模块空闲
            tx_ready <= 1'b0;                   //准备过程结束
            tx_en  <= 1'b1;                   //拉高发送使能信号
        end
    end
end


endmodule

