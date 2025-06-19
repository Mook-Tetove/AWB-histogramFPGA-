`timescale 1ns / 1ps
module Hist_static #(                                               
    parameter       H 			= 1920 	,
	parameter       V 			= 1080 	,
	parameter       DATA_WIDTH 	= 8     
)(
    input 			i_clk				,      
    input 			i_rst				,      
    input  [7:0] 	img_data			, 
    input 			img_hs				, 
    input 			img_vs				,  	output          ram_hist_done       ,
	input           dr_ram_rd_en        ,
    input  [8 :0]   dr_ram_rd_addr      ,
	output reg      dr_ram_rd_valid     ,
    output [31:0]   dr_ram_rd_dout      



);

reg [15:0] x_cnt, y_cnt;
reg [299:0] img_hs_d  ;
reg [299:0] img_vs_d  ;
reg dr_ram_rd_en_1d;reg dr_ram_rd_en_2d;
reg [DATA_WIDTH - 1 : 0] img_data_1d  ;
reg [DATA_WIDTH - 1 : 0] img_data_2d  ;
reg [DATA_WIDTH - 1 : 0] img_data_3d  ;
reg [DATA_WIDTH - 1 : 0] img_data_4d  ;
reg [DATA_WIDTH - 1 : 0] img_data_5d  ;

always@(posedge i_clk) 
begin 
	if(i_rst)begin  
		img_hs_d    <= 'd0 ;
        img_vs_d    <= 'd0 ;
		img_data_1d <= 'd0 ;
        img_data_2d <= 'd0 ;
        img_data_3d <= 'd0 ;
        img_data_4d <= 'd0 ;
        img_data_5d <= 'd0 ;
        dr_ram_rd_valid <= 'd0;  
		dr_ram_rd_en_1d <= 'd0;
	end else begin
		img_hs_d    <= { img_hs_d[298:0] , img_hs};
		img_vs_d    <= { img_vs_d[298:0] , img_vs};
		img_data_1d <= img_data      ;
        img_data_2d <= img_data_1d   ;
        img_data_3d <= img_data_2d   ;
        img_data_4d <= img_data_3d   ;
        img_data_5d <= img_data_4d   ;
		dr_ram_rd_en_1d <= dr_ram_rd_en;
		dr_ram_rd_valid <= dr_ram_rd_en;		dr_ram_rd_en_2d <= dr_ram_rd_en_1d;
	end
end 
assign ram_hist_done = ram_zero_flag_2d && !ram_zero_flag_1d;
always@(posedge i_clk) 
begin 
	if(i_rst)  
		x_cnt <= 'd0;	
	else if(img_hs)
		x_cnt <= x_cnt + 1;
	else 
		x_cnt <= 'd0;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		y_cnt <= 'd0;
	else if(!img_vs)
		y_cnt <= 'd0;
	else if(img_hs_d[0] && !img_hs)
		y_cnt <= y_cnt + 1;
	else 
		y_cnt <= y_cnt;
end 

reg          gl_ram_wr_en    ;
reg          gl_ram_rd_en    ;
reg  [8 :0]  gl_ram_wr_addr  ;
reg  [8 :0]  gl_ram_rd_addr  ;
reg  [31:0]  gl_ram_wr_din   ;
wire [31:0]  gl_ram_rd_dout  ;




reg [31:0] wr_con_pix_cnt;
reg [8 :0] ram_zero_cnt ;
reg        ram_zero_flag;
reg [8 :0] ram_zero_cnt_1d  ;
reg        ram_zero_flag_1d ;
reg [8 :0] ram_zero_cnt_2d  ;
reg        ram_zero_flag_2d ;

wire       gl_ram_rd_en_sel  ;
wire [8:0] gl_ram_rd_addr_sel;

assign gl_ram_rd_en_sel   = ram_zero_flag ? 'd1 : gl_ram_rd_en;  
assign gl_ram_rd_addr_sel = ram_zero_flag ? ram_zero_cnt : gl_ram_rd_addr;  
						 

Hist_ram0 gray_level_ram (
  .clka				(i_clk				        ),      // input wire clka
  .wea				(gl_ram_wr_en				),      // input wire [0 : 0] wea
  .addra			(gl_ram_wr_addr				),      // input wire [8 : 0] addra
  .dina				(gl_ram_wr_din				),      // input wire [31 : 0] dina
  .clkb				(i_clk				        ),      // input wire clkb
  .enb				(gl_ram_rd_en_sel           ),      // input wire enb
  .addrb			(gl_ram_rd_addr_sel         ),      // input wire [8 : 0] addrb
  .doutb			(gl_ram_rd_dout				)       // output wire [31 : 0] doutb
);
Hist_ram0 data_reg_ram (
  .clka				(i_clk				        ),      // input wire clka
  .wea				(ram_zero_flag_1d			),      // input wire [0 : 0] wea
  .addra			(ram_zero_cnt_1d			),      // input wire [8 : 0] addra
  .dina				(gl_ram_rd_dout				),      // input wire [31 : 0] dina
  .clkb				(i_clk				        ),      // input wire clkb
  .enb				(dr_ram_rd_en               ),      // input wire enb
  .addrb			(dr_ram_rd_addr             ),      // input wire [8 : 0] addrb
  .doutb			(dr_ram_rd_dout             )       // output wire [31 : 0] doutb
);


always@(posedge i_clk) 
begin 
	if(i_rst)begin
		ram_zero_cnt_1d  <= 'd0;
        ram_zero_flag_1d <= 'd0;
        ram_zero_cnt_2d  <= 'd0;
        ram_zero_flag_2d <= 'd0;
	end else begin
		ram_zero_cnt_1d  <= ram_zero_cnt  ;
        ram_zero_flag_1d <= ram_zero_flag ;
        ram_zero_cnt_2d  <= ram_zero_cnt_1d  ;
        ram_zero_flag_2d <= ram_zero_flag_1d ;
	end
end 

reg [31:0] his_acc_cnt;
always@(posedge i_clk) 
begin 
	if(i_rst)  
		his_acc_cnt <= 'd0;
	else if(ram_zero_flag_1d)
		his_acc_cnt <= his_acc_cnt + gl_ram_rd_dout;
	else
		his_acc_cnt <= 'd0;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		ram_zero_cnt <= 'd0;
	else if(ram_zero_flag && ram_zero_cnt == 255)
		ram_zero_cnt <= 'd0;
	else if(ram_zero_flag)
		ram_zero_cnt <= ram_zero_cnt + 1;
end 
always@(posedge i_clk) 
begin 
	if(i_rst)  
		ram_zero_flag <= 'd0;
	else if(ram_zero_flag && ram_zero_cnt == 255)
		ram_zero_flag <= 'd0;
	else if(img_vs_d[3] && !img_vs_d[2])
		ram_zero_flag <= 'd1;
	else 
		ram_zero_flag <= ram_zero_flag;
end 


always@(posedge i_clk) 
begin 
	if(i_rst)  
		wr_con_pix_cnt <= 'd1;
	else if(img_data_2d != img_data_1d)
		wr_con_pix_cnt <= 'd1;
	else if(img_data_2d == img_data_1d && img_hs_d[1])
		wr_con_pix_cnt <= wr_con_pix_cnt + 1;
end 
always@(posedge i_clk) 
begin 
	if(i_rst)  
		gl_ram_wr_addr <= 'd0;
	else if(ram_zero_flag)
		gl_ram_wr_addr <= ram_zero_cnt;
	else 
		gl_ram_wr_addr <= img_data_2d;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		gl_ram_wr_en <= 'd0;
	else if(ram_zero_flag)
		gl_ram_wr_en <= 'd1;
	else if(img_hs_d[1] && (img_data_2d != img_data_1d) && img_vs_d[2])
		gl_ram_wr_en <= 'd1;
	else 
		gl_ram_wr_en <= 'd0;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		gl_ram_rd_en <= 'd0;
	else if(img_hs)
		gl_ram_rd_en <= 'd1;
	else 
		gl_ram_rd_en <= 'd0;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		gl_ram_rd_addr <= 'd0;
	else 
		gl_ram_rd_addr <= img_data;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		gl_ram_wr_din <= 'd0;
	else if(img_hs_d[1])
		gl_ram_wr_din <= gl_ram_rd_dout + wr_con_pix_cnt;
	else 
		gl_ram_wr_din <= 'd0;
end 

endmodule
