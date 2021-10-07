module SevenHexDecoder (
	input        [3:0] i_hex,
	input        [4:0] i_effectt,
	output logic [6:0] o_seven_ten,
	output logic [6:0] o_seven_one,
	output logic [6:0] o_seven_key7,
	output logic [6:0] o_seven_key6,
	output logic [6:0] o_seven_key5,
	output logic [6:0] o_seven_key4,
	output logic [6:0] o_seven_key3,
	output logic [6:0] o_seven_key2
);

/* The layout of seven segment display, 1: dark
 *    00
 *   5  1
 *    66
 *   4  2
 *    33
 */
parameter D0 = 7'b1000000;
parameter D1 = 7'b1111001;
parameter D2 = 7'b0100100;
parameter D3 = 7'b0110000;
parameter D4 = 7'b0011001;
parameter D5 = 7'b0010010;
parameter D6 = 7'b0000010;
parameter D7 = 7'b1011000;
parameter D8 = 7'b0000000;
parameter D9 = 7'b0010000;


parameter D_left_top  = 7'b1011111;
parameter D_left_btm  = 7'b1101111;
parameter D_btm       = 7'b1110111;
parameter D_right_btm = 7'b1111011;
parameter D_right_top = 7'b1111101;
parameter D_top       = 7'b1111110;



always_comb begin
	o_seven_one =  '1;
	o_seven_ten =  '1;
	o_seven_key2 = '1;
	o_seven_key3 = '1;
	o_seven_key4 = '1;
	o_seven_key5 = '1;
	o_seven_key6 = '1;
	o_seven_key7 = '1;
	case(i_effectt)
		5'd0: begin
			case(i_hex)
				4'h0: begin o_seven_ten = D0; o_seven_one = D0; end
				4'h1: begin o_seven_ten = D0; o_seven_one = D1; end
				4'h2: begin o_seven_ten = D0; o_seven_one = D2; end
				4'h3: begin o_seven_ten = D0; o_seven_one = D3; end
				4'h4: begin o_seven_ten = D0; o_seven_one = D4; end
				4'h5: begin o_seven_ten = D0; o_seven_one = D5; end
				4'h6: begin o_seven_ten = D0; o_seven_one = D6; end
				4'h7: begin o_seven_ten = D0; o_seven_one = D7; end
				4'h8: begin o_seven_ten = D0; o_seven_one = D8; end
				4'h9: begin o_seven_ten = D0; o_seven_one = D9; end
				4'ha: begin o_seven_ten = D1; o_seven_one = D0; end
				4'hb: begin o_seven_ten = D1; o_seven_one = D1; end
				4'hc: begin o_seven_ten = D1; o_seven_one = D2; end
				4'hd: begin o_seven_ten = D1; o_seven_one = D3; end
				4'he: begin o_seven_ten = D1; o_seven_one = D4; end
				4'hf: begin o_seven_ten = D1; o_seven_one = D5; end
				default: begin o_seven_ten = D0; o_seven_one = D0; end
			endcase
		end

		5'd1: begin o_seven_one = D_top; end
		5'd2: begin o_seven_ten = D_top; end
		5'd3: begin o_seven_key2 = D_top; end
		5'd4: begin o_seven_key3 = D_top; end
		5'd5: begin o_seven_key4 = D_top; end
		5'd6: begin o_seven_key5 = D_top; end
		5'd7: begin o_seven_key6 = D_top; end
		5'd8: begin o_seven_key7 = D_top; end
		5'd9: begin o_seven_key7 = D_left_top; end
		5'd10: begin o_seven_key7 = D_left_btm; end
		5'd11: begin o_seven_key7 = D_btm; end
		5'd12: begin o_seven_key6 = D_btm; end
		5'd13: begin o_seven_key5 = D_btm; end
		5'd14: begin o_seven_key4 = D_btm; end
		5'd15: begin o_seven_key3 = D_btm; end
		5'd16: begin o_seven_key2 = D_btm; end
		5'd17: begin o_seven_ten = D_btm; end
		5'd18: begin o_seven_one = D_btm; end
		5'd19: begin o_seven_one = D_right_btm; end
		5'd20: begin o_seven_one = D_right_top; end
	endcase
end


endmodule
