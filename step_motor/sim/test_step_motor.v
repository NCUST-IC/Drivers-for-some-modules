module test_step_motor;

reg clk;
reg rst_n;
wire [3:0] out;

// 生成时钟信号
always begin
    #5 clk = ~clk;
end

// 初始化
initial begin
    clk = 0;
    rst_n = 0;
    // 等待一段时间，然后释放复位信号
    #10 rst_n = 1;
    // 等待一段时间，然后开始仿真
    #10;
    
    // 仿真时间
    #500;
    $finish; // 结束仿真
end

// 实例化步进电机控制模块
step_motor #(
	 .cnt_speed('d5)
)uut 
(
    .clk(clk),
    .rst_n(rst_n),
    .out(out)
);

// 显示输出序列
initial begin
    $monitor("Time = %0t, out = %b", $time, out);
end

endmodule
