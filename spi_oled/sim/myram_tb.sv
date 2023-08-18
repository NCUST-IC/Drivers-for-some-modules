// RAM仿真测试文件
module myram_tb;

reg clk;
reg [9:0] write_addr;
reg [7:0] write_data;
reg [9:0] read_addr;
wire [7:0] read_data;

// 实例化待测试的myram模块
myram uut (
    .clk(clk),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_addr(read_addr),
    .read_data(read_data)
);

// 时钟生成器
always begin
    #5 clk = ~clk;
end

//initial $readmemh("yuanshen.txt", memory);

// 仿真开始
initial begin
    clk = 0;
    write_addr = 10'b000_000_0000;
	 read_addr  = 10'b000_000_0000;
    write_data = 8'h00;


    // 停止仿真前多次读取数据
	 //integer i;
	 //generate
    #10;
    for (integer i = 0; i <= 1023; i = i + 8) begin
        read_addr = read_addr + i;
        #10;
    end
	 //endgenerate


    // 停止仿真
    #10;
    $stop;
end

endmodule
