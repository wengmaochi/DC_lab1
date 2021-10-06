module Debounce (
	input  i_in,         // i_start or key[0]
	input  i_clk,
	input  i_rst_n,
	input  i_pause,
	input  i_speedup,
	output [2:0]o_debounced,
	output [2:0] o_neg,
	output [2:0] o_pos
);

parameter CNT_N = 7;
localparam CNT_BIT = $clog2(CNT_N+1);

logic [2:0] o_debounced_r, o_debounced_w;
logic [CNT_BIT-1:0] counter_r0 ;
logic [CNT_BIT-1:0] counter_w0 ;
logic [CNT_BIT-1:0] counter_r1 ;
logic [CNT_BIT-1:0] counter_w1 ;
logic [CNT_BIT-1:0] counter_r2 ;
logic [CNT_BIT-1:0] counter_w2 ;


logic [2:0] neg_r, neg_w, pos_r, pos_w;

assign o_debounced = o_debounced_r;
assign o_pos = pos_r;
assign o_neg = neg_r;

always_comb begin
	// i_in
	if (i_in != o_debounced_r[0]) begin
		counter_w0 = counter_r0 - 1;
	end else begin
		counter_w0 = CNT_N;
	end
	if (counter_r0 == 0) begin
		o_debounced_w[0] = ~o_debounced_r[0];
	end else begin
		o_debounced_w[0] = o_debounced_r[0];
	end
	pos_w[0] = ~o_debounced_r[0] &  o_debounced_w[0]; // detect i_in posedge // w==1
	neg_w[0] =  o_debounced_r[0] & ~o_debounced_w[0]; // detect i_in negedge // r==1

	//i_pause
	if (i_pause != o_debounced_r[1]) begin
		counter_w1 = counter_r1 - 1;
	end else begin
		counter_w1 = CNT_N;
	end
	if (counter_r1 == 0) begin
		o_debounced_w[1] = ~o_debounced_r[1];
	end else begin
		o_debounced_w[1] = o_debounced_r[1];
	end
	pos_w[1] = ~o_debounced_r[1] &  o_debounced_w[1]; // detect i_in posedge // w==1
	neg_w[1] =  o_debounced_r[1] & ~o_debounced_w[1]; // detect i_in negedge // r==1


	//i_speedup
	if (i_speedup != o_debounced_r[2]) begin
		counter_w2 = counter_r2 - 1;
	end else begin
		counter_w2 = CNT_N;
	end
	if (counter_r2 == 0) begin
		o_debounced_w[2] = ~o_debounced_r[2];
	end else begin
		o_debounced_w[2] = o_debounced_r[2];
	end
	pos_w[2] = ~o_debounced_r[2] &  o_debounced_w[2]; // detect i_in posedge // w==1
	neg_w[2] =  o_debounced_r[2] & ~o_debounced_w[2]; // detect i_in negedge // r==1
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		o_debounced_r <= '0;
		counter_r0 <= '0;
		counter_r1 <= '0;
		counter_r2 <= '0;
		neg_r <= '0;
		pos_r <= '0;
	end else begin
		o_debounced_r <= o_debounced_w;
		counter_r0 <= counter_w0;
		counter_r1 <= counter_w1;
		counter_r2 <= counter_w2;
		neg_r <= neg_w;
		pos_r <= pos_w;
	end
end

endmodule
