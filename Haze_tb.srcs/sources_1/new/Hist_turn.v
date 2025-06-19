`timescale 1ns / 1ps
module Hist_awb_turn(        
	input        i_clk     ,
	input        i_rst     ,   
	input [7:0]  img_r     ,            
    input [7:0]  img_g     ,
    input [7:0]  img_b     ,    
	input        img_hs    ,
	input        img_vs    ,
	input        o_img_hs  ,
    input        o_img_vs  ,
    input [7:0]  o_img_r   ,
    input [7:0]  o_img_g   ,
    input [7:0]  o_img_b   ,
    output reg awb_mode,  // 添加模式选择标志作为输出
    output reg [31:0] sat_sumr, // R通道高亮饱和像素计数
    output reg [31:0] sat_sumb, // B通道高亮饱和像素计数
    output reg [31:0] h_sumg    // G通道高明度像素计数
);
parameter   RB_TH  =  240 ;
parameter   G_TH   =  200 ;

reg  		r_ram_rd_en    ;
reg  [8:0]	r_ram_rd_addr  ;
wire [31:0]	r_ram_rd_dout  ;

reg  		g_ram_rd_en    ;
reg  [8:0]	g_ram_rd_addr  ;
wire [31:0]	g_ram_rd_dout  ;

reg  		b_ram_rd_en    ;
reg  [8:0]	b_ram_rd_addr  ;
wire [31:0]	b_ram_rd_dout  ;


reg [15:0] x_cnt, y_cnt    ;
reg [15:0] img_hs_d        ;
reg [15:0] img_vs_d        ;
wire       ram_hist_done   ;
reg [15:0] ram_hist_done_d ;


reg g_ram_rd;
reg g_ram_rd_1d;
reg [7:0] g_ram_rd_cnt;
reg [31:0] g_ram_acc;
reg r_ram_rd;
reg r_ram_rd_1d;
reg [7:0] r_ram_rd_cnt;
reg [31:0] r_ram_acc;
reg b_ram_rd;
reg b_ram_rd_1d;
reg [7:0] b_ram_rd_cnt;
reg [31:0] b_ram_acc;
reg awb_turn;


Hist_static Hist_static_r(
    .i_clk				 (i_clk		     ),      
    .i_rst				 (i_rst		     ),      
    .img_data			 (img_r  	     ), 
    .img_hs				 (img_hs		 ), 
    .img_vs				 (img_vs		 ), 
	.ram_hist_done       (ram_hist_done  ),
	.dr_ram_rd_en        (r_ram_rd),
    .dr_ram_rd_addr      (r_ram_rd_addr  ),
	.dr_ram_rd_valid     (),
    .dr_ram_rd_dout      (r_ram_rd_dout  )
);

Hist_static Hist_static_g(
    .i_clk				 (i_clk		     ),      
    .i_rst				 (i_rst		     ),      
    .img_data			 (img_g  	     ), 
    .img_hs				 (img_hs		 ), 
    .img_vs				 (img_vs		 ),    
	.dr_ram_rd_en        (g_ram_rd    ),
    .dr_ram_rd_addr      (g_ram_rd_addr  ),
	.dr_ram_rd_valid     ( ),
    .dr_ram_rd_dout      (g_ram_rd_dout  )
);

Hist_static Hist_static_b(
    .i_clk				 (i_clk		     ),      
    .i_rst				 (i_rst		     ),      
    .img_data			 (img_b  	     ), 
    .img_hs				 (img_hs		 ), 
    .img_vs				 (img_vs		 ),    
	.dr_ram_rd_en        (r_ram_rd    ),
    .dr_ram_rd_addr      (r_ram_rd_addr  ),
	.dr_ram_rd_valid     ( ),
    .dr_ram_rd_dout      (b_ram_rd_dout  )
);

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

always@(posedge i_clk) 
begin 
	if(i_rst)begin  
		img_hs_d    <= 'd0 ;
        img_vs_d    <= 'd0 ;
		ram_hist_done_d <= 'd0;
	end else begin
		img_hs_d    <= { img_hs_d[14:0] , img_hs};
		img_vs_d    <= { img_vs_d[14:0] , img_vs};
		ram_hist_done_d <= {ram_hist_done_d[14:0],ram_hist_done};
	end
end 

always@(posedge i_clk) 
begin 
	if(i_rst)begin  
		img_hs_d    <= 'd0 ;
        img_vs_d    <= 'd0 ;
		ram_hist_done_d <= 'd0;
	end else begin
		img_hs_d    <= { img_hs_d[14:0] , img_hs};
		img_vs_d    <= { img_vs_d[14:0] , img_vs};
		ram_hist_done_d <= {ram_hist_done_d[14:0],ram_hist_done};
    end
end 




always@(posedge i_clk)begin
	g_ram_rd_1d <= g_ram_rd; 
	r_ram_rd_1d <= r_ram_rd;
	b_ram_rd_1d <= b_ram_rd;
end
always@(posedge i_clk) 
begin 
	if(i_rst) 
		g_ram_rd <= 'd0;
	else if(g_ram_rd_cnt == (255 - G_TH - 1) && g_ram_rd)
		g_ram_rd <= 'd0;
	else if(ram_hist_done)
		g_ram_rd <= 'd1;
	else 
		g_ram_rd <= g_ram_rd;
end 

always@(posedge i_clk) 
begin 
	if(i_rst) 
		r_ram_rd <= 'd0;
	else if(r_ram_rd_cnt == (255 - RB_TH - 1) && r_ram_rd)
		r_ram_rd <= 'd0;
	else if(ram_hist_done)
		r_ram_rd <= 'd1;
	else 
		r_ram_rd <= r_ram_rd;
end

always@(posedge i_clk) 
begin 
	if(i_rst) 
		g_ram_rd_cnt <= 'd0;
	else if(g_ram_rd_cnt == (255 - G_TH - 1) && g_ram_rd)
		g_ram_rd_cnt <= 'd0;
	else if(g_ram_rd)
		g_ram_rd_cnt <= g_ram_rd_cnt + 'd1;
	else 
		g_ram_rd_cnt <= g_ram_rd_cnt;
end 

always@(posedge i_clk) 
begin 
	if(i_rst) 
		r_ram_rd_cnt <= 'd0;
	else if(r_ram_rd_cnt == (255 - RB_TH - 1) && r_ram_rd)
		r_ram_rd_cnt <= 'd0;
	else if(r_ram_rd)
		r_ram_rd_cnt <= r_ram_rd_cnt + 'd1;
	else 
		r_ram_rd_cnt <= r_ram_rd_cnt;
end 

always@(posedge i_clk) 
begin 
	if(i_rst) 
		g_ram_acc <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		g_ram_acc <= 'd0;
	else if(g_ram_rd_1d)
		g_ram_acc <= g_ram_acc + g_ram_rd_dout;
	else 
		g_ram_acc <= g_ram_acc;
end 

always@(posedge i_clk) 
begin 
	if(i_rst) 
		r_ram_acc <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		r_ram_acc <= 'd0;
	else if(r_ram_rd_1d)
		r_ram_acc <= r_ram_acc + r_ram_rd_dout;
	else 
		r_ram_acc <= r_ram_acc;
end 

always@(posedge i_clk) 
begin 
	if(i_rst) 
		b_ram_acc <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		b_ram_acc <= 'd0;
	else if(r_ram_rd_1d)
		b_ram_acc <= b_ram_acc + b_ram_rd_dout;
	else 
		b_ram_acc <= b_ram_acc;
end 

always@(posedge i_clk) 
begin 
	if(i_rst) 
		g_ram_rd_addr <= G_TH;
	else if(g_ram_rd_1d && !g_ram_rd)
		g_ram_rd_addr <= G_TH;
	else if(g_ram_rd)
		g_ram_rd_addr <= g_ram_rd_addr + 'd1;
	else 
		g_ram_rd_addr <= g_ram_rd_addr;
end 

always@(posedge i_clk) 
begin 
	if(i_rst) 
		r_ram_rd_addr <= RB_TH;
	else if(r_ram_rd_1d && !r_ram_rd)
		r_ram_rd_addr <= RB_TH;
	else if(r_ram_rd)
		r_ram_rd_addr <= r_ram_rd_addr + 'd1;
	else 
		r_ram_rd_addr <= r_ram_rd_addr;
end 


always@(posedge i_clk) 
begin 
	if(i_rst) 
		awb_turn <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		awb_turn <= (b_ram_acc > g_ram_acc || r_ram_acc > g_ram_acc) ? 'd1 : 'd0;
	else 
		awb_turn <= awb_turn;
end 

reg   [7:0]    mv_img_r_1d    ; 
reg   [7:0]    mv_img_g_1d    ; 
reg   [7:0]    mv_img_b_1d    ; 

wire  [7:0]    mv_img_r       ; 
wire  [7:0]    mv_img_g       ; 
wire  [7:0]    mv_img_b       ; 
wire           mth_img_hs     ;
wire           mth_img_vs     ;
wire  [7:0]    mth_img_r      ;
wire  [7:0]    mth_img_g      ;
wire  [7:0]    mth_img_b      ;

always@(posedge i_clk) 
begin 
	mv_img_r_1d <= mv_img_r;
    mv_img_g_1d <= mv_img_g;
    mv_img_b_1d <= mv_img_b;
end 

Hist_move_top Hist_move_top(
	.i_clk     (i_clk ),
	.i_rst     (i_rst ),   
	.img_r     (img_r ),  
    .img_g     (img_g ),
    .img_b     (img_b ),
	.img_hs    (img_hs),
	.img_vs    (img_vs),
	.o_img_hs  (),
	.o_img_vs  (),
	.o_img_r   (mv_img_r),
    .o_img_g   (mv_img_g),
    .o_img_b   (mv_img_b)

);

Hist_match Hist_match(            
	.i_clk     (i_clk ),
	.i_rst     (i_rst ),   
	.img_r     (img_r ),  
    .img_g     (img_g ),
    .img_b     (img_b ),
	.img_hs    (img_hs),
	.img_vs    (img_vs),
	.o_img_hs  (mth_img_hs),
	.o_img_vs  (mth_img_vs),
	.o_img_r   (mth_img_r ),
    .o_img_g   (mth_img_g ),
    .o_img_b   (mth_img_b )

);

assign o_img_hs =                             mth_img_hs ;
assign o_img_vs =                             mth_img_vs ;
assign o_img_r  = awb_turn == 1 ? mv_img_r :  mth_img_r  ;
assign o_img_g  = awb_turn == 1 ? mv_img_g :  mth_img_g  ;
assign o_img_b  = awb_turn == 1 ? mv_img_b :  mth_img_b  ;

endmodule
