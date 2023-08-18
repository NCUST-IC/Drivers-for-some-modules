module spi_oled(
	input  clk,    // Clock
	input  rst_n,
								//对应四线SPI 0.96寸oled屏幕引脚
	output oled_cs,		//cs
	output oled_sck,		//d0
	output oled_rst,		//res
	output oled_dc,		//dc

	output oled_mosi		//d1
);

parameter 	CLK_FRE = 50; //输入的时钟频率 Mhz
parameter 	SPI_FRE = 100; //SPI SCK工作时钟频率 10kHz

//存一张图片
wire [9:0] read_addr;
wire [7:0] read_data;
myram myram_m0(
	.clk 	 	(clk			),

	.write_addr (				),
	.write_data (				),

	.read_addr 	(read_addr		),
	.read_data 	(read_data		)
	);

//ssd1306时序控制
wire send_busy,send_en,send_dc;
wire [7:0] send_data,recv_data;
ssd1306_ctrl#(
	.CLK_FRE (CLK_FRE	 )
	) 
ssd1306_ctrl_u0(
	.clk 	  		(clk 		),
	.rst_n 			(rst_n 		),
	
	.read_addr 		(read_addr	),
	.read_data 		(read_data	),
	
	.oled_rst 		(oled_rst 	),
	.send_busy	  	(send_busy 	),
	.send_en   		(send_en 	),
	.send_dc   		(send_dc 	),
	.send_data 		(send_data 	)
	);




parameter CLK_DIV = CLK_FRE * 50 / SPI_FRE;
reg [9:0] clk_delay = 0;
reg spi_clk = 0;
always@(posedge clk) clk_delay <= (clk_delay == CLK_DIV)? 0 : clk_delay + 'd1;
always@(posedge clk) spi_clk <= clk_delay >= CLK_DIV / 2;

  spi_master #(
    .CPOL(0),                    // Clock polarity
    .FREE_RUNNING_SPI_CLK(0),    // Free-running SPI clock
    .MOSI_DATA_WIDTH(8),         // MOSI data width
    .WRITE_MSB_FIRST(1),         // Write MSB first
    .MISO_DATA_WIDTH(8),         // MISO data width
    .READ_MSB_FIRST(1)           // Read MSB first
  ) my_spi_master (
    .clk(clk),                   // System clock
    .nrst(rst_n),                 // Reset
    .spi_clk(spi_clk),           // Prescaler clock
    .spi_wr_cmd(send_en),     // SPI write command
    .spi_rd_cmd(),     // SPI read command
    .spi_busy(send_busy),         // SPI busy signal
    .mosi_data(send_data),       // MOSI data
    .miso_data(),       // MISO data
    .clk_pin(oled_sck),           // Clock pin
    .ncs_pin(oled_cs),           // Chip select pin
    .mosi_pin(oled_mosi),         // MOSI pin
    .oe_pin(),             // Output enable pin
    .miso_pin(),          // MISO pin
	 
	 .recv_dc(send_dc),
	 .spi_dc(oled_dc)
  );



endmodule
