`timescale 1ns / 1ps
module Hist_match(            
	input        i_clk     ,
	input        i_rst     ,   
	input [7:0]  img_r     ,  
    input [7:0]  img_g     ,
    input [7:0]  img_b     ,
	input        img_hs    ,
	input        img_vs    ,
	output       o_img_hs  ,
	output       o_img_vs  ,
	output [7:0] o_img_r   ,
    output [7:0] o_img_g   ,
    output [7:0] o_img_b   

);

reg  		r_ram_rd_en    ;
reg  [8:0]	r_ram_rd_addr  ;
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

wire       ram_hist_done   ;
reg [15:0] ram_hist_done_d ;

Hist_static Hist_static_r(
    .i_clk				 (i_clk		     ),      
    .i_rst				 (i_rst		     ),      
    .img_data			 (img_r  	     ), 
    .img_hs				 (img_hs		 ), 
    .img_vs				 (img_vs		 ), 
	.ram_hist_done       (ram_hist_done  ),
	.dr_ram_rd_en        (r_ram_rd_en    ),
    .dr_ram_rd_addr      (r_ram_rd_addr  ),
	.dr_ram_rd_valid     (dr_ram_rd_valid_r),
    .dr_ram_rd_dout      (r_ram_rd_dout  )
);

Hist_static Hist_static_g(
    .i_clk				 (i_clk		     ),      
    .i_rst				 (i_rst		     ),      
    .img_data			 (img_g  	     ), 
    .img_hs				 (img_hs		 ), 
    .img_vs				 (img_vs		 ),    
	.dr_ram_rd_en        (g_ram_rd_en    ),
    .dr_ram_rd_addr      (g_ram_rd_addr  ),
	.dr_ram_rd_valid     (dr_ram_rd_valid_g ),
    .dr_ram_rd_dout      (g_ram_rd_dout  )
);

Hist_static Hist_static_b(
    .i_clk				 (i_clk		     ),      
    .i_rst				 (i_rst		     ),      
    .img_data			 (img_b  	     ), 
    .img_hs				 (img_hs		 ), 
    .img_vs				 (img_vs		 ),    
	.dr_ram_rd_en        (b_ram_rd_en    ),
    .dr_ram_rd_addr      (b_ram_rd_addr  ),
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


//-------------- rb_hist_reg_rd ---------------
reg [31:0] g_hist_acc_1d;
reg        ram_hist_done_1d;
reg [31:0] r_hist_acc;
reg        r_ram_rd_en_1d;
reg        r_ram_rd_en_2d;
reg        r_acc_match_succ;
reg        r_acc_match_succ_1d;
reg        r_ram_rd_valid_1d;
reg        r_ram_rd_valid_2d;
reg        r_ram_rd_valid_3d;

reg [31:0] b_hist_acc;
reg        b_ram_rd_en_1d;
reg        b_ram_rd_en_2d;
reg        b_acc_match_succ;
reg        b_acc_match_succ_1d;
reg        b_ram_rd_valid_1d;
reg        b_ram_rd_valid_2d;
reg        b_ram_rd_valid_3d;
reg [31:0] g_ram_rd_dout_1d;
reg [31:0] g_ram_rd_dout_2d;
reg [31:0] g_ram_rd_dout_3d;
reg [31:0] g_ram_rd_dout_4d;
reg [31:0] g_hist_acc;

reg        g_ram_rd_en_1d;
reg        g_ram_rd_en_2d;
reg        g_ram_rd_valid_1d;

reg        dr_ram_rd_valid_g_1d;
reg        dr_ram_rd_valid_b_1d;
reg        dr_ram_rd_valid_r_1d;
reg  [7:0]    r_acc_match_succ_d;
reg  [7:0]    b_acc_match_succ_d;

always@(posedge i_clk) 
begin 
	r_ram_rd_en_1d <= r_ram_rd_en; 
	r_ram_rd_en_2d <= r_ram_rd_en_1d;
	r_acc_match_succ_1d <= r_acc_match_succ;
	r_ram_rd_valid_1d   <= r_ram_rd_valid;
	r_ram_rd_valid_2d   <= r_ram_rd_valid_1d;
	r_ram_rd_valid_3d   <= r_ram_rd_valid_2d;
	g_ram_rd_valid_1d <= g_ram_rd_valid;
	dr_ram_rd_valid_g_1d <= dr_ram_rd_valid_g;
	dr_ram_rd_valid_b_1d <= dr_ram_rd_valid_b;
    dr_ram_rd_valid_r_1d <= dr_ram_rd_valid_r;
	r_acc_match_succ_d <= {r_acc_match_succ_d[6:0],r_acc_match_succ};
end

always@(posedge i_clk) 
begin 
	b_ram_rd_en_1d      <= b_ram_rd_en; 
	b_ram_rd_en_2d      <= b_ram_rd_en_1d;
	b_acc_match_succ_1d <= b_acc_match_succ;
	b_ram_rd_valid_1d   <= b_ram_rd_valid;
	b_ram_rd_valid_2d   <= b_ram_rd_valid_1d;
	b_ram_rd_valid_3d   <= b_ram_rd_valid_2d;
	b_acc_match_succ_d <= {b_acc_match_succ_d[6:0],b_acc_match_succ};
end


assign r_ram_rd_valid = !dr_ram_rd_valid_r_1d && dr_ram_rd_valid_r;
assign g_ram_rd_valid = !dr_ram_rd_valid_g_1d && dr_ram_rd_valid_g;
assign b_ram_rd_valid = !dr_ram_rd_valid_b_1d && dr_ram_rd_valid_b;



always@(posedge i_clk) 
begin 
	if(i_rst)  
		r_ram_rd_en <= 'd0;	
	else if(ram_hist_done || ((r_acc_match_succ_1d || r_acc_match_succ ) && r_ram_rd_addr < 256))
		r_ram_rd_en <= 'd1;
	else 
		r_ram_rd_en <= 'd0;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		b_ram_rd_en <= 'd0;	
	else if(ram_hist_done || ((b_acc_match_succ_1d || b_acc_match_succ ) && b_ram_rd_addr < 256))
		b_ram_rd_en <= 'd1;
	else 
		b_ram_rd_en <= 'd0;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		r_ram_rd_addr <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		r_ram_rd_addr <= 'd0;
	else if(!r_ram_rd_en_2d && r_ram_rd_en_1d)
		r_ram_rd_addr <= r_ram_rd_addr + 'd1;
	else 
		r_ram_rd_addr <= r_ram_rd_addr;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		b_ram_rd_addr <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		b_ram_rd_addr <= 'd0;
	else if(!b_ram_rd_en_2d && b_ram_rd_en_1d)
		b_ram_rd_addr <= b_ram_rd_addr + 'd1;
	else 
		b_ram_rd_addr <= b_ram_rd_addr;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		r_hist_acc <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		r_hist_acc <= 'd0;
	else if(r_ram_rd_valid)
		r_hist_acc <= r_hist_acc + r_ram_rd_dout;
	else 
		r_hist_acc <= r_hist_acc;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		b_hist_acc <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		b_hist_acc <= 'd0;
	else if(b_ram_rd_valid)
		b_hist_acc <= b_hist_acc + b_ram_rd_dout;
	else 
		b_hist_acc <= b_hist_acc;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		r_acc_match_succ <= 'd0;
	else if(r_acc_match_succ_d[2] && r_ram_rd_addr != 256)
		r_acc_match_succ <= r_hist_acc <= g_hist_acc ? 'd1 : 'd0;
	else if(g_ram_rd_valid_1d )
		r_acc_match_succ <= r_hist_acc <= g_hist_acc && r_hist_acc >= g_hist_acc_1d;
	else 
		r_acc_match_succ <= 'd0;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		b_acc_match_succ <= 'd0;
	else if(b_acc_match_succ_d[2] && b_ram_rd_addr != 256)
		b_acc_match_succ <= b_hist_acc <= g_hist_acc ? 'd1 : 'd0;
	else if(g_ram_rd_valid_1d )
		b_acc_match_succ <= b_hist_acc <= g_hist_acc && b_hist_acc >= g_hist_acc_1d;
	else 
		b_acc_match_succ <= 'd0;
end 

reg g_hist_ram_rd;
reg [7:0] g_ram_rd_cnt;

always@(posedge i_clk) 
begin 
	if(i_rst)  
		g_hist_ram_rd <= 'd0;
	else if(g_ram_rd_addr > 255)
		g_hist_ram_rd <= 'd0;
	else if(r_ram_rd_valid_2d && !r_acc_match_succ)
		g_hist_ram_rd <= 'd1;
	else 
		g_hist_ram_rd <= g_hist_ram_rd;
end

always@(posedge i_clk) 
begin 
	if(i_rst)  
		g_ram_rd_cnt <= 'd0;
	else if(r_ram_rd_valid_2d && !r_acc_match_succ)
		g_ram_rd_cnt <= 'd0;
	else if(g_ram_rd_cnt == 5 && g_hist_ram_rd)
		g_ram_rd_cnt <= 'd0;
	else if(g_hist_ram_rd)
		g_ram_rd_cnt <= g_ram_rd_cnt + 'd1;
	else 
		g_ram_rd_cnt <= g_ram_rd_cnt;
end  
  
wire [7:0] r_match_value;
assign r_match_value = r_acc_match_succ == 'd1 ? (r_hist_acc - g_hist_acc_1d >= g_hist_acc - r_hist_acc) ? g_ram_rd_addr > 3 ? g_ram_rd_addr - 3 : 'd0 : g_ram_rd_addr > 2 ? g_ram_rd_addr - 2 : 'd0 :'d0;  
wire [7:0] b_match_value;
assign b_match_value = b_acc_match_succ == 'd1 ? (b_hist_acc - g_hist_acc_1d >= g_hist_acc - b_hist_acc) ? g_ram_rd_addr > 3 ? g_ram_rd_addr - 3 : 'd0 : g_ram_rd_addr > 2 ? g_ram_rd_addr - 2 : 'd0 :'d0;  


//-------------- g_hist_reg_rd ---------------
reg g_rd_en_1d;
reg r_rd_busy_1d;
reg [7:0] r_rd_busy_d;
reg [7:0] b_rd_busy_d;

assign r_rd_busy = (r_ram_rd_en || r_acc_match_succ);
assign b_rd_busy = (b_ram_rd_en || b_acc_match_succ);

always@(posedge i_clk) 
begin 
	g_ram_rd_en_1d <= g_ram_rd_en;
	g_ram_rd_en_2d <= g_ram_rd_en_1d;
	r_rd_busy_d <= {r_rd_busy_d[6:0],r_rd_busy};
    b_rd_busy_d <= {b_rd_busy_d[6:0],b_rd_busy};
end

wire busy = ((r_rd_busy || r_rd_busy_d[0] || r_rd_busy_d[1]) || (b_rd_busy || b_rd_busy_d[0] || b_rd_busy_d[1]));
assign g_rd_en = ((g_ram_rd_cnt == 1)  && g_hist_ram_rd)&& !busy&&(g_ram_rd_addr<256);
always@(posedge i_clk) 
begin 
	if(i_rst)begin  
		g_ram_rd_dout_1d <= 'd0;
        g_ram_rd_dout_2d <= 'd0;
        g_ram_rd_dout_3d <= 'd0;
        g_ram_rd_dout_4d <= 'd0;
		g_hist_acc_1d    <= 'd0;
	end else begin
		g_ram_rd_dout_1d <= g_ram_rd_dout    ;
        g_ram_rd_dout_2d <= g_ram_rd_dout_1d ;
        g_ram_rd_dout_3d <= g_ram_rd_dout_2d ;
        g_ram_rd_dout_4d <= g_ram_rd_dout_3d ;   
		g_hist_acc_1d    <= g_hist_acc;
		g_rd_en_1d <= g_rd_en;
		r_rd_busy_1d <= r_rd_busy;
	end
end 
always@(posedge i_clk) 
begin 
	if(i_rst)  
		g_ram_rd_en <= 'd0;	
	else if((ram_hist_done || (g_rd_en_1d || g_rd_en)))
		g_ram_rd_en <= 'd1;
	else 
		g_ram_rd_en <= 'd0;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		g_ram_rd_addr <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		g_ram_rd_addr <= 'd0;
	else if(!g_ram_rd_en_2d && g_ram_rd_en_1d)
		g_ram_rd_addr <= g_ram_rd_addr + 'd1;
	else 
		g_ram_rd_addr <= g_ram_rd_addr;
end 

always@(posedge i_clk) 
begin 
	if(i_rst)  
		g_hist_acc <= 'd0;
	else if(!img_vs_d[0] && img_vs)
		g_hist_acc <= 'd0;
	else if(g_ram_rd_valid)
		g_hist_acc <= g_hist_acc + g_ram_rd_dout;
	else 
		g_hist_acc <= g_hist_acc;
end 

//---------  REG DATA -------------
wire [7:0] r_dout;
Hist_ram0 r_channal (
  .clka				(i_clk				        ),      // input wire clka
  .wea				(r_acc_match_succ			),      // input wire [0 : 0] wea
  .addra			(r_ram_rd_addr				),      // input wire [8 : 0] addra
  .dina				(r_match_value			    ),      // input wire [31 : 0] dina
  .clkb				(i_clk				        ),      // input wire clkb
  .enb				(img_hs           			),      // input wire enb
  .addrb			({1'b0,img_r}               ),      // input wire [8 : 0] addrb
  .doutb			(r_dout						)       // output wire [31 : 0] doutb
);
wire [7:0] b_dout;
Hist_ram0 b_channal (
  .clka				(i_clk				        ),      // input wire clka
  .wea				(b_acc_match_succ			),      // input wire [0 : 0] wea
  .addra			(b_ram_rd_addr				),      // input wire [8 : 0] addra
  .dina				(b_match_value			    ),      // input wire [31 : 0] dina
  .clkb				(i_clk				        ),      // input wire clkb
  .enb				(img_hs           			),      // input wire enb
  .addrb			({1'b0,img_b}              	),      // input wire [8 : 0] addrb
  .doutb			(b_dout						)       // output wire [31 : 0] doutb
);


reg [7:0] img_g_1d;
always@(posedge i_clk) 
begin 
	if(i_rst)  
		img_g_1d <= 'd0;
	else 
		img_g_1d <= img_g;
end 




assign o_img_hs = img_hs_d[0] ;
assign o_img_vs = img_vs_d[0] ;
assign o_img_r  = r_dout[7:0] ;
assign o_img_g  = img_g_1d    ;
assign o_img_b  = b_dout[7:0] ;
endmodule
