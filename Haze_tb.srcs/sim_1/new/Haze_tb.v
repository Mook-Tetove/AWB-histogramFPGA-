`timescale 1ns / 1ps
module Haze_tb();         

wire 						per_img_vsync   					;
wire 						per_img_href   						;
wire [23:0]    				data_out  							;
wire 						herf_edge							;
wire [23:0] 				rgb   								;

wire  						post_img_vsync						;
wire  						post_img_href 						;
wire [23:0] 			    post_img_gray 						;
wire [23:0] 				per_img_gray  						;
wire [7 :0]     			post_img_R    						;
wire [7 :0]      			post_img_G    						;
wire [7 :0]      			post_img_B    						;



			

reg 						clk  								;
reg 						rst_n								;


reg  [7 :0]                 src_data_8bit                       ;
reg  [7 :0]                 random_data_8bit                    ;
reg  [23:0]                 random_data_24bit                    ;

reg  [15:0] 				hs_cnt								;
reg  [15:0] 				vs_cnt								;
reg 						per_img_href_r						;
reg 						per_img_href_rr						;

//----------------------------------------------------------------
//****====    wr_rd_data    ====****//
parameter 					HCNT  		=  360	,
							VCNT  		=  240	;
reg  [23 :0] 				o_r 		= 1'b1			  ;
reg  [24 :0] 				image_cnt 	= 1'b0			  ;
reg  [23 :0] 				image[(HCNT )*(VCNT) - 1'b1:0];

initial begin
    $readmemh("C:/Users/mookt/Documents/MATLAB/Joint simulation/rgb_data_hex.txt",image);
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)begin
        o_r 	  <= 1'b0; 
        image_cnt <= 1'b0;   
    end else if(per_img_vsync && per_img_href)begin
        o_r 	  <= image [image_cnt];
        image_cnt <= image_cnt + 1;
    end else if (image_cnt == HCNT*VCNT)begin
        o_r       <= 'd0;
        image_cnt <= 1'd0;
    end else begin
        o_r <= 'h0;
        image_cnt <= image_cnt;
    end
end

reg  [23:0] 					image_txt		;
reg  [31:0] 					pixel_cnt		;
reg  [6 :0]						cnt_wr_start 	;

always@(posedge clk) 
begin
	if(!rst_n)
		cnt_wr_start <= 'd0;
	else if(cnt_wr_start == 11) 
		cnt_wr_start <= 11;
	else if(post_img_vsync_d && !post_img_vsync) 
		cnt_wr_start <= cnt_wr_start + 1;
	else	
		cnt_wr_start <= cnt_wr_start;
end
reg post_img_vsync_d;
always@(posedge clk) 
begin
	if(!rst_n)
		post_img_vsync_d <= 'd0;
	else 
		post_img_vsync_d <= post_img_vsync;
end

initial begin
	image_txt = $fopen("C:/Users/mookt/Documents/MATLAB/Joint simulation/fpga_rgb.txt");
end
always@(posedge clk) 
begin
	if(!rst_n)
		pixel_cnt <=0 ;
	else if(post_img_href && cnt_wr_start >= 1) begin
	//else if(post_img_href) begin
		$fwrite(image_txt, "%h\n" , post_img_gray);
		pixel_cnt = pixel_cnt + 1'b1 ;
		if (pixel_cnt == VCNT*HCNT + 10000)
		$stop ;
	end
end
//****    end    ====****//
//---------------------------------------------------------------	
assign herf_edge = (per_img_href_r && !per_img_href) ? 1'b1 : 1'b0;

always@(posedge clk)
begin
    per_img_href_r 	<= per_img_href;
    per_img_href_rr <= per_img_href_r;
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		hs_cnt <= 1'b0;
	else if(per_img_href)
		hs_cnt <= hs_cnt + 1'b1 ;
	else
		hs_cnt <= 1'b0;
end
    
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		vs_cnt <= 1'b0;
	else if(per_img_vsync)
	begin
		if(herf_edge)
			vs_cnt <= vs_cnt + 1'b1;
		else          
			vs_cnt <= vs_cnt;
	end
	else
		vs_cnt <= 1'b0;
end

/*
Hist_static #(
	.H 			(1920 	 ),
	.V 			(1080 	 ),
	.DATA_WIDTH (8       )
)Hist_static(
    .i_clk				(clk	),      
    .i_rst				(!rst_n  ),      
    .img_data				(rgb), 
    .img_hs				(per_img_href ) , 
    .img_vs				(per_img_vsync)
);*/
/*
Hist_match Hist_match(
	.i_clk     (clk),
	.i_rst     (!rst_n),   
	.img_r     (rgb[23:16]),
    .img_g     (rgb[15: 8]),
    .img_b     (rgb[7 : 0]),
	.img_hs    (per_img_href ),
	.img_vs    (per_img_vsync),
	.o_img_hs  (post_img_href),
	.o_img_vs  (post_img_vsync),
	.o_img_r   (post_img_R),
    .o_img_g   (post_img_G),
    .o_img_b   (post_img_B)

);*/

/*
Hist_move_r Hist_move(
	.i_clk     (clk),
	.i_rst     (!rst_n),   
	.img_r     (rgb[23:16]),
    .img_g     (rgb[15: 8]),
    .img_b     (rgb[7 : 0]),
	.img_hs    (per_img_href ),
	.img_vs    (per_img_vsync)

);*/
Hist_awb_turn Hist_awb_turn(
	.i_clk     (clk),
	.i_rst     (!rst_n),   
	.img_r     (rgb[23:16]),
    .img_g     (rgb[15: 8]),
    .img_b     (rgb[7 : 0]),
	.img_hs    (per_img_href ),
	.img_vs    (per_img_vsync),
	.o_img_hs  (post_img_href),
	.o_img_vs  (post_img_vsync),
	.o_img_r   (post_img_R),
    .o_img_g   (post_img_G),
    .o_img_b   (post_img_B)

);

assign post_img_gray = {post_img_R,post_img_G,post_img_B};

assign per_img_gray = o_r;

frame_timing #(
	.HCNT (HCNT),
	.VCNT (VCNT)
)
u0_ft(
    .vga_clk     				(clk				),  
    .sys_rst_n   				(rst_n				),  
    .pix_data    				(per_img_gray		),  
    .pix_data_req				(pix_data_req		),  
    .rgb_valid   				(per_img_href		),  
    .hsync       				(        			),  
    .vsync       				(per_img_vsync		),  
    .rgb         				(  		rgb	)//rgb 
); 

initial
begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial
begin
    rst_n = 1'b0;
    repeat(100) @(posedge clk);
    rst_n = 1'b1;
end

endmodule

module frame_timing #(
	parameter HCNT = 640 ,
	parameter VCNT =480

)(
    input   wire            vga_clk     				,  
    input   wire            sys_rst_n   				,  
    input   wire   [23:0]   pix_data    				,  
				
    output  reg             pix_data_req				,  
    output  wire            rgb_valid   				,  
    output  reg             hsync       				,  
    output  reg             vsync       				,  
    output  reg    [23:0]   rgb         				 
);

parameter 				H_SYNC    = 12'd40				,
						H_BACK    = 12'd14  			, 
						H_LEFT    = 12'd0  				, 
						H_VALID   = HCNT 			, 
						H_RIGHT   = 12'd10  			, 
						H_FRONT   = 12'd8				,
						H_TOTAL   = HCNT + 80  			; 
				
parameter 				V_SYNC    = 12'd50   			, 
						V_BACK    = 12'd5  				,
						V_TOP     = 12'd4  				, 
						V_VALID   = VCNT			    , 
						V_BOTTOM  = 12'd2 				, 
						V_FRONT   = 12'd8   			, 
						V_TOTAL   = VCNT + 80		    ; 

reg  [11:0]   			cnt_h          					;   
reg  [11:0]   			cnt_v           				;  
reg 					v_valid							; 

always@(posedge vga_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        cnt_h <= 12'd0;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_h <= 12'd0;
    else
        cnt_h <= cnt_h + 1'd1;
end

always @(*)begin
    hsync <= (cnt_h <= H_SYNC - 1'd1) ? 1'b0 : 1'b1  ;
end

always@(posedge vga_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        cnt_v <= 12'd0 ;
    else    if((cnt_v == V_TOTAL - 1'd1) && (cnt_h == H_TOTAL-1'd1))
        cnt_v <=  12'd0 ;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_v <= cnt_v + 1'd1 ;
    else
        cnt_v <= cnt_v ;
end

always @(*)begin
    vsync <= (cnt_v <= V_SYNC - 1'd1) ? 1'b0 : 1'b1  ;

end

assign  rgb_valid = (((cnt_h >= H_SYNC + H_BACK  + H_LEFT)
                    && (cnt_h < H_SYNC + H_BACK  + H_LEFT + H_VALID ))
                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                    && (cnt_v < V_SYNC + V_BACK + V_TOP   + V_VALID )))
                    ? 1'b1 : 1'b0;
					
always@(posedge vga_clk or  negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		v_valid <= 'd0;
	else if(cnt_h ==2111 && cnt_v == 1122)
		v_valid <= 'd0;
	else if(cnt_h ==191 && cnt_v == 43)
		v_valid <= 'd1;
	else 
		v_valid <= v_valid;
end	

always @(*)begin
    pix_data_req = (((cnt_h >= H_SYNC + H_BACK + H_LEFT - 1)
                    && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID - 1))
                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                    && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
                    ? 1'b1 : 1'b0;
end

always @(*)begin
    rgb <= rgb_valid == 1'b1 ? pix_data : 'b0 ;
end

endmodule