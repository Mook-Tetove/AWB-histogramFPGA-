module Hist_move_l(            
	input        i_clk     ,
	input        i_rst     ,   
	input [7:0]  img_r     ,        
    input [7:0]  img_g     ,
    input [7:0]  img_b     ,
	input        img_hs    ,
	input        img_vs    ,
    output [31:0] img_l_oa_max   ,
    output [31:0] img_l_mv_phase  

);

parameter STEP   = 4 ;
parameter MIN_TH = 4 ;
parameter MAX_TH = 200;

reg  		r_ram_rd_en    ;
reg  [8:0]	r_ram_rd_addr  ;
reg  [8:0]	r_ram_rd_addr_1d  ;
reg  [8:0]	g_ram_rd_addr_1d  ;
reg  [8:0]	b_ram_rd_addr_1d  ;
wire 		r_ram_rd_valid ;
wire [31:0]	r_ram_rd_dout  ;

reg  		g_ram_rd_en    ;
reg  [8:0]	g_ram_rd_addr  ;
wire 		g_ram_rd_valid ;
wire [31:0]	g_ram_rd_dout  ;

reg  		b_ram_rd_en    ;
reg  [8:0]	b_ram_rd_addr  ;
wire 		b_ram_rd_valid ;
wire [31:0]	b_ram_rd_dout  ;


reg [15:0] x_cnt, y_cnt    ;
reg [15:0] img_hs_d        ;
reg [15:0] img_vs_d        ;
reg [8:0] r_start_pos;
reg       r_st_move_1d;
reg       r_st_move_2d;
wire       ram_hist_done   ;
reg [15:0] ram_hist_done_d ;

Hist_static Hist_static_r(
    .i_clk				 (i_clk		     ),      
    .i_rst				 (i_rst		     ),      
    .img_data			 (img_r  	     ), 
    .img_hs				 (img_hs		 ), 
    .img_vs				 (img_vs		 ), 
	.ram_hist_done       (ram_hist_done  ),
	.dr_ram_rd_en        (r_st_move_1d    ),
    .dr_ram_rd_addr      (r_ram_rd_addr_1d  ),
	.dr_ram_rd_valid     (dr_ram_rd_valid_r),
    .dr_ram_rd_dout      (r_ram_rd_dout  )
);

Hist_static Hist_static_g(
    .i_clk				 (i_clk		     ),      
    .i_rst				 (i_rst		     ),      
    .img_data			 (img_g  	     ), 
    .img_hs				 (img_hs		 ), 
    .img_vs				 (img_vs		 ),    
	.dr_ram_rd_en        (r_st_move_1d    ),
    .dr_ram_rd_addr      (g_ram_rd_addr_1d  ),
	.dr_ram_rd_valid     (dr_ram_rd_valid_g ),
    .dr_ram_rd_dout      (g_ram_rd_dout  )
);

Hist_static Hist_static_b(
    .i_clk				 (i_clk		     ),      
    .i_rst				 (i_rst		     ),      
    .img_data			 (img_b  	     ), 
    .img_hs				 (img_hs		 ), 
    .img_vs				 (img_vs		 ),    
	.dr_ram_rd_en        (r_st_move_1d    ),
    .dr_ram_rd_addr      (b_ram_rd_addr_1d  ),
	.dr_ram_rd_valid     (dr_ram_rd_valid_b ),
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

//-------------- hist move start -----------
reg start_m_1d;
reg [7:0] r_start_pos_1d;
reg [7:0] r_start_pos_2d;
always@(posedge i_clk) 
begin 
	if(i_rst)begin  
		img_hs_d    <= 'd0 ;
        img_vs_d    <= 'd0 ;
		ram_hist_done_d <= 'd0;
		r_ram_rd_addr_1d <= 'd0;
        g_ram_rd_addr_1d <= 'd0;
        b_ram_rd_addr_1d <= 'd0;
		r_start_pos_1d <= 'd0;


	end else begin
		img_hs_d    <= { img_hs_d[14:0] , img_hs};
		img_vs_d    <= { img_vs_d[14:0] , img_vs};
		ram_hist_done_d <= {ram_hist_done_d[14:0],ram_hist_done};
		r_start_pos_1d <= r_start_pos;
		r_start_pos_2d <= r_start_pos_1d;
		r_ram_rd_addr_1d <= r_ram_rd_addr;
        g_ram_rd_addr_1d <= g_ram_rd_addr;
        b_ram_rd_addr_1d <= b_ram_rd_addr;
		start_m_1d <= start_m;
	end
end 

reg r_st_move;
wire start_m = g_ram_rd_addr == 255 && r_st_move;
always@(posedge i_clk) 
begin 
	if(i_rst) 
		r_st_move <= 'd0;
	else if(start_m || r_start_pos >= MAX_TH)
		r_st_move <= 'd0;
	else if(ram_hist_done || start_m_1d )
		r_st_move <= 'd1;
	else 
		r_st_move <= r_st_move;
end 

always@(posedge i_clk) 
begin 
	if(i_rst) 
		g_ram_rd_addr <= 'd0;
	else if(g_ram_rd_addr == 255 && r_st_move)
		g_ram_rd_addr <= 'd0;
	else if(r_st_move)
		g_ram_rd_addr <= g_ram_rd_addr + 'd1;
	else 
		g_ram_rd_addr <= g_ram_rd_addr;
end 

always@(posedge i_clk) 
begin 
	if(i_rst) 
		b_ram_rd_addr <= 'd0;
	else if(b_ram_rd_addr == 255 && r_st_move)
		b_ram_rd_addr <= 'd0;
	else if(r_st_move)
		b_ram_rd_addr <= b_ram_rd_addr + 'd1;
	else 
		b_ram_rd_addr <= b_ram_rd_addr;
end 




always@(posedge i_clk) begin r_st_move_1d <= r_st_move; r_st_move_2d <= r_st_move_1d; end

always@(posedge i_clk) 
begin 
	if(i_rst) 
		r_start_pos <= MIN_TH;	else if(!img_vs_d[0] && img_vs)
		r_start_pos <= MIN_TH;
	else if(g_ram_rd_addr == 254 && r_st_move)
		r_start_pos <= r_start_pos + STEP;
	else 
		r_start_pos <= r_start_pos;
end 

always@(posedge i_clk) 
begin 
	if(i_rst || img_vs) 
		r_ram_rd_addr <= r_start_pos;
	else if(r_start_pos >= MAX_TH)
		r_ram_rd_addr <= MAX_TH;
	else if(g_ram_rd_addr == 255 && r_st_move)
		r_ram_rd_addr <= r_start_pos;
    else if(r_ram_rd_addr >= 255)
		r_ram_rd_addr <= 256;
	else if(r_st_move)
		r_ram_rd_addr <= r_ram_rd_addr + 'd1;
	else 
		r_ram_rd_addr <= r_ram_rd_addr;
end 

reg [31:0] oa_eara;
wire [31:0] r_rd_dout;
wire [31:0] g_rd_dout;
wire [31:0] b_rd_dout;
wire [31:0] min_rd_dout;
assign r_rd_dout = r_ram_rd_addr == 256 ? 0 : r_ram_rd_dout;
assign g_rd_dout = g_ram_rd_dout;
assign b_rd_dout = b_ram_rd_dout;
assign min_rd_dout = r_rd_dout <= g_rd_dout && r_rd_dout <= b_rd_dout ? r_rd_dout :
				     b_rd_dout <= g_rd_dout && b_rd_dout <= r_rd_dout ? b_rd_dout : g_rd_dout;

always@(posedge i_clk) 
begin 
	if(i_rst) 
		oa_eara <= 'd0;
	else if(r_st_move_1d && !r_st_move)
		oa_eara <= 'd0;
	else if(r_st_move_2d)
		oa_eara <= oa_eara + min_rd_dout;
	else 
		oa_eara <= oa_eara;
end 

reg [31:0] oa_max;
reg [31:0] move_phase;
always@(posedge i_clk) 
begin 
	if(i_rst) 
		oa_max <= 'd0;
	else if(oa_eara >= oa_max && r_st_move_1d && !r_st_move)
		oa_max <= oa_eara;
	else 
		oa_max <= oa_max;
end 
always@(posedge i_clk) 
begin 
	if(i_rst) 
		move_phase <= 'd0;
	else if(oa_eara >= oa_max && r_st_move_1d && !r_st_move)
		move_phase <= r_start_pos_2d;
	else 
		move_phase <= move_phase;
end assign img_l_oa_max   = oa_max     ;assign img_l_mv_phase = move_phase ;
endmodule