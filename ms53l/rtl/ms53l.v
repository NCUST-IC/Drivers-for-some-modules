module ms53l(
	input			clk,
	input			rst_n,

	input			key_in,			//start test
	input			uart_rx,			//connect with  tx
	output		uart_tx,			//connect with  rx
	//MS53L1M
	input			uart_rx_ms53l,
	output		uart_tx_ms531,

	    //seg_led interface
	 output  reg             led_out,
    //output    [5:0]  seg_sel  ,       // 数码管位选信号
    //output    [7:0]  seg_led  ,       // 数码管段选信号
    output  wire            stcp        , 
    output  wire            shcp        , 
    output  wire            ds          , 
    output  wire            oe            
	 
);

assign uart_tx = uart_rx_ms53l;
/*
wire	uart_tx_data;
//------------------------ uart_tx_inst ------------------------
uart_tx
#(
    .UART_BPS    (UART_BPS  ),
    .CLK_FREQ    (CLK_FREQ  )
)
uart_tx_inst
(
    .sys_clk    (clk    ),  //input             sys_clk
    .sys_rst_n  (rst_n  ),  //input             sys_rst_n
    .pi_data    (uart_send_data_cal    ),  //input     [7:0]   pi_data
    .pi_flag    (uart_send_en_cal    ),  //input             pi_flag
                
    .tx         (uart_tx_data         )   //output            tx
);
*/
//reg define
reg touch_key_dly1 ; //touch_key延迟一个时钟信号
reg touch_key_dly2 ; //touch_key延迟两个时钟信号
//wire define
wire touch_en ; //触摸使能信号
//根据触摸按键信号的下降沿判断触摸了触摸按键
assign touch_en = touch_key_dly2 & (~touch_key_dly1);

//对touch_key信号延迟两个时钟周期用来产生触摸按键信号
always@(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
	 touch_key_dly1 <= 1'b0;
	 touch_key_dly2 <= 1'b0;
   end
   else begin
	 touch_key_dly1 <= key_in;
	 touch_key_dly2 <= touch_key_dly1;
   end
end

always@(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0)
		led_out <= 1'b1;
   else if(touch_en)
		led_out <= ~led_out;
end

//wire define   
wire       uart_recv_done;              //UART_receive_end
wire [7:0] uart_recv_data;              //UART_receive_data
wire       uart_send_en;                
wire [7:0] uart_send_data;              
wire       uart_tx_busy;                //UART_state_busy_send

wire	[7:0]	data_ms53l;

//parameter define
parameter  CLK_FREQ = 50000000;        
parameter  UART_BPS = 115200;    

//uart_recv_data form rxd  --> uart_done uart_data[7:0]     
uart_recv #(                          
    .CLK_FREQ       (CLK_FREQ),         
    .UART_BPS       (UART_BPS))        
u_uart_recv(                 
    .clk            (clk), 
    .rst_n          (rst_n),
    
    .uart_rxd       (uart_rx_ms53l),
    .uart_done      (uart_recv_done),
    .uart_data      (uart_recv_data),
	 .data_two_byte  (data_two_byte_wire)
    );

//uart_send_data to txd -->   uart_tx_busy uart_txd[7:0]
uart_send #(                          
    .CLK_FREQ       (CLK_FREQ),         
    .UART_BPS       (UART_BPS))         
u_uart_send(                 
    .clk            (clk),
    .rst_n          (rst_n),
     
    .tx_en          (uart_send_en),
    .tx_din         (uart_send_data),
    .uart_tx_busy   (uart_tx_busy),
    .uart_txd       (uart_tx_ms531)
    );

//send byte data
reg_7Byte reg_7Byte_u(
	.clk(clk),
	.rst_n(rst_n),
	
	.flag_start(touch_en),
	.tx_busy(uart_tx_busy), 
	
    .tx_en(uart_send_en),                  
    .tx_data(uart_send_data)
);


//wire       uart_send_en_cal;                
//wire [7:0] uart_send_data_cal;     
////recive data caculate
//dist_calculate dist_calculate_u(
//	.clk(clk),
//	.rst_n(rst_n),
//
//	.rx_data_en(uart_recv_done),
//	.rx_data(uart_recv_data),
//	
//	.data(data_wire),
//	.tx_en(uart_send_en_cal),                  
//   .tx_data(uart_send_data_cal)
//);


wire [15:0] data_wire;
wire [15:0] data_two_byte_wire;
//-------------seg7_dynamic_inst--------------
seg_595_dynamic    seg_595_dynamic_inst
(
    .sys_clk    (clk   		),   
    .sys_rst_n  (rst_n 		),   
    //.data       ({5'b00000,data_two_byte_wire} ),   
	 .data       (data_two_byte_wire), 
	 //.data       (data_wire), 
    .point      (6'b0      ),
    .seg_en     (1'b1      ),
    .sign       (1'b0      ),

    .stcp       (stcp      ),   
    .shcp       (shcp      ),   
    .ds         (ds        ),   
    .oe         (oe        )
);



endmodule

