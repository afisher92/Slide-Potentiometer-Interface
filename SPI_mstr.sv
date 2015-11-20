module SPI_mstr(done,rd_data,SCLK,SS_n,MOSI,MISO,clk,rst_n,wrt,cmd);

input clk,rst_n,wrt;
input [15:0] cmd;

output reg done,SS_n;
output [15:0] rd_data;

output SCLK, MOSI;
input MISO;

reg [4:0] bit_cnt,sclk_cnt; // counters
reg [15:0] shft_reg;
logic set_done,clr_done,rst_cnt,shft,clr_SS_n,set_SS_n;

SPI_slave s1(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI));

//states
typedef enum reg [1:0]{IDLE,SHIFTING_BITS, BACK_PORCH}state_t;
state_t state, nxt_state;

//flop for shft_reg
always_ff @ (posedge clk or negedge rst_n)
	if(!rst_n)
	 shft_reg <= 16'h0000;
	else if (wrt) 
	 shft_reg <= cmd;
	else if (shft)
	 shft_reg <= {shft_reg[14:0],MISO};


assign MOSI = shft_reg[15];
assign rd_data = shft_reg;

//flop to set done
always_ff @ (posedge clk or negedge rst_n)
	if(!rst_n)
	 done <= 1'b0;
	else if(clr_done)
	 done <= 1'b0;
	else if(set_done)
	 done <= 1'b1;

//flop for SS_n with async rest
always_ff @ (posedge clk or negedge rst_n)
	if(!rst_n)
	 SS_n <= 1'b1;
	else if(clr_SS_n)
	 SS_n <= 1'b1;
	else if(set_SS_n)
	 SS_n <= 1'b0;

//counter to know when data transfer is complete
always_ff @ (posedge clk or negedge rst_n)
	if (!rst_cnt | rst_n)
	 bit_cnt <= 5'b00000;
	else if(shft)
	 bit_cnt <= bit_cnt + 1;
	
//counter for SCLK
always_ff @ (posedge clk or negedge rst_n)
	if(rst_cnt | !rst_n)
	 sclk_cnt <= 5'b11000;
	else
	 sclk_cnt <= sclk_cnt - 1;
//flop for states
always_ff @ (posedge clk or !rst_n)
	if(!rst_n)
	 state <= IDLE;
	else
	 state <= nxt_state;

//states
always_comb begin
nxt_state = IDLE;
set_done = 1'b0;
clr_done = 1'b0;
rst_cnt = 1'b0;
clr_SS_n = 1'b0;
set_SS_n  = 1'b0;
	
//state machine	
case (state)
	IDLE: begin
	rst_cnt = 1'b1;
	if (wrt) begin
	 nxt_state = SHIFTING_BITS;
	 clr_done = 1'b1;
	 set_SS_n = 1'b1; // make SS_n 0
	end
	 else nxt_state = IDLE;
	end

	SHIFTING_BITS: begin
	shft = &sclk_cnt;
	if (bit_cnt == 5'b10000) begin
	 nxt_state <= BACK_PORCH;
	 rst_cnt = 1'b1;
	end
	else 
	 nxt_state = SHIFTING_BITS;
	end

	BACK_PORCH: begin
	if (!sclk_cnt[3:0]) begin
	 nxt_state = IDLE;
	 rst_cnt = 1'b1;
	 set_done = 1'b1; 
	 clr_SS_n = 1'b1;
	end
	else
	 nxt_state = BACK_PORCH;
	end
	default : nxt_state = IDLE;
	endcase
	end
endmodule
