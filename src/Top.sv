module Top (
	input        i_clk,
	input        i_start, //key0
	input        i_rst_n, //key1
	input 		 i_pause,  //key2
	input        i_speedup,  //key3
	output [3:0] o_random_out
);

// please check out the working example in lab1 README (or Top_exmaple.sv) first


	//=============states===============
	parameter S_idle = 4'd0;
	parameter S_tempo7 = 4'd7;
	parameter S_tempo6 = 4'd6;
	parameter S_tempo5 = 4'd5;
    parameter S_tempo4 = 4'd4;
	parameter S_tempo3 = 4'd3;
	parameter S_tempo2 = 4'd2;
	parameter S_tempo1 = 4'd1;
	// state + 7 = pause
	parameter S_pause7 = 4'd14;
	parameter S_pause6 = 4'd13;
	parameter S_pause5 = 4'd12;
	parameter S_pause4 = 4'd11;
	parameter S_pause3 = 4'd10;
	parameter S_pause2 = 4'd9;
	parameter S_pause1 = 4'd8;

	parameter S_finished = 4'd15;
	//===========speed for each state : 幾個clock cycle顯示一次數字======== //亂設 -> 之後要調整成跟 LFSR 整體組合(六萬多的那個數字) 互質的數字
	// parameter clk_limit7 = 26'd2500000; //0.05秒一個數字 
	// parameter clk_limit6 = 26'd5000000;
	// parameter clk_limit5 = 26'd7500000;
	// parameter clk_limit4 = 26'd10000000;
	// parameter clk_limit3 = 26'd15000000;
	// parameter clk_limit2 = 26'd25000000;
	// parameter clk_limit1 = 26'd50000000; //1秒一個數字
	// local test parameter (in order to adapt to local slow clk frequency)
	parameter clk_limit7 = 26'd50;
	parameter clk_limit6 = 26'd500;
	parameter clk_limit5 = 26'd1000;
	parameter clk_limit4 = 26'd2500;
	parameter clk_limit3 = 26'd5000;
	parameter clk_limit2 = 26'd10000;
	parameter clk_limit1 = 26'd15000;
	

	//===========count it takes to transfer to next state : 顯示幾個數字之後跳下一個state========
	parameter num_limit7 = 5'd30;
	parameter num_limit6 = 5'd15;
	parameter num_limit5 = 5'd7;
	parameter num_limit4 = 5'd5;
	parameter num_limit3 = 5'd3;
	parameter num_limit2 = 5'd2;
	parameter num_limit1 = 5'd2;
// ==========output buffers=============
	logic [3:0] o_random_out_w, o_random_out_r;


// ==================Registers & wires ============
	logic [3:0]  state_w, state_r;
	logic [25:0] counter_clk_w, counter_clk_r;    // 數字與數字之間的counter, bits 數待確認。 若最慢的tempo是一秒跑一個數字，log2(50M) = 25.5，我先設 26 bits。 // given clock : 50M Hz
	logic [4:0]  counter_num_w, counter_num_r;    // 一個state總共出現幾次數字的counter, bits 數待確認
	logic   	 clk_en7, clk_en6, clk_en5, clk_en4, clk_en3, clk_en2, clk_en1;
	logic        state_en7, state_en6, state_en5, state_en4, state_en3, state_en2, state_en1;
	logic [15:0] LFSR_w, LFSR_r; //LFSR Sequence, for random number

// =============== Output assignments===========
	assign o_random_out = o_random_out_r ;

	assign clk_en7 = (counter_clk_r > clk_limit7) ? 1'b1 : 1'b0;
	assign clk_en6 = (counter_clk_r > clk_limit6) ? 1'b1 : 1'b0;
	assign clk_en5 = (counter_clk_r > clk_limit5) ? 1'b1 : 1'b0;
	assign clk_en4 = (counter_clk_r > clk_limit4) ? 1'b1 : 1'b0;
	assign clk_en3 = (counter_clk_r > clk_limit3) ? 1'b1 : 1'b0;
	assign clk_en2 = (counter_clk_r > clk_limit2) ? 1'b1 : 1'b0;
	assign clk_en1 = (counter_clk_r > clk_limit1) ? 1'b1 : 1'b0;
	assign state_en7 = (counter_num_r >= num_limit7) ? 1'b1 : 1'b0;
	assign state_en6 = (counter_num_r >= num_limit6) ? 1'b1 : 1'b0;
	assign state_en5 = (counter_num_r >= num_limit5) ? 1'b1 : 1'b0;
	assign state_en4 = (counter_num_r >= num_limit4) ? 1'b1 : 1'b0;
	assign state_en3 = (counter_num_r >= num_limit3) ? 1'b1 : 1'b0;
	assign state_en2 = (counter_num_r >= num_limit3) ? 1'b1 : 1'b0;
	assign state_en1 = (counter_num_r >= num_limit3) ? 1'b1 : 1'b0;
	
//  ==========Combinational Circuits==========
always_comb begin 

	//random seed never stops, even at IDLE state 
	LFSR_w[14:0] = LFSR_r[15:1] ;
	LFSR_w[15] = ( (LFSR_r[0] ^ LFSR_r[2]) ^ LFSR_r[3] ) ^ LFSR_r[5];

	//FSM
	case(state_r)
	
		S_idle: begin

			if ( i_start ) begin
				state_w = S_tempo5; //一開始去tempo5
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0];
			end

			else begin
				state_w = S_idle ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_tempo7: begin

			if ( i_pause ) begin
				// determine if the state goes to pause
				state_w = S_pause7 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if speed up 
				state_w = S_tempo7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( state_en7 && clk_en7 ) begin   ///////////////
				// time to change state
				state_w = S_tempo6 ; 
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( clk_en7 ) begin
				// determine if it's time to change output number
				state_w = state_r ;
				counter_clk_w = 26'd0 ;
				counter_num_w = counter_num_r + 1'b1;
				o_random_out_w = LFSR_r[3:0];
			end

			else begin
				// just keep counting
				state_w = state_r ;
				counter_clk_w = counter_clk_r + 1'b1 ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_tempo6: begin

			if ( i_pause ) begin
				// determine if the state goes to pause
				state_w = S_pause6 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if speed up 
				state_w = S_tempo7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( state_en6 && clk_en6 ) begin
				// time to change state
				state_w = S_tempo5 ; 
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( clk_en6 ) begin
				// determine if it's time to change output number
				state_w = state_r ;
				counter_clk_w = 26'd0 ;
				counter_num_w = counter_num_r + 1'b1;
				o_random_out_w = LFSR_r[3:0];
			end

			else begin
				// just keep counting
				state_w = state_r ;
				counter_clk_w = counter_clk_r + 1'b1 ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_tempo5: begin

			if ( i_pause ) begin
				// determine if the state goes to pause
				state_w = S_pause5 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if speed up 
				state_w = S_tempo7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( state_en5 && clk_en5 ) begin
				// time to change state
				state_w = S_tempo4 ; 
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( clk_en5 ) begin
				// determine if it's time to change output number
				state_w = state_r ;
				counter_clk_w = 26'd0 ;
				counter_num_w = counter_num_r + 1'b1;
				o_random_out_w = LFSR_r[3:0];
			end

			else begin
				// just keep counting
				state_w = state_r ;
				counter_clk_w = counter_clk_r + 1'b1 ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_tempo4: begin

			if ( i_pause ) begin
				// determine if the state goes to pause
				state_w = S_pause4 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if speed up 
				state_w = S_tempo7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( state_en4 && clk_en4 ) begin
				// time to change state
				state_w = S_tempo3 ; 
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( clk_en4 ) begin
				// determine if it's time to change output number
				state_w = state_r ;
				counter_clk_w = 26'd0 ;
				counter_num_w = counter_num_r + 1'b1;
				o_random_out_w = LFSR_r[3:0];
			end

			else begin
				// just keep counting
				state_w = state_r ;
				counter_clk_w = counter_clk_r + 1'b1 ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_tempo3: begin

			if ( i_pause ) begin
				// determine if the state goes to pause
				state_w = S_pause3 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if speed up 
				state_w = S_tempo7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( state_en3 && clk_en3 ) begin
				// time to change state
				state_w = S_tempo2 ; 
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( clk_en3 ) begin
				// determine if it's time to change output number
				state_w = state_r ;
				counter_clk_w = 26'd0 ;
				counter_num_w = counter_num_r + 1'b1;
				o_random_out_w = LFSR_r[3:0];
			end

			else begin
				// just keep counting
				state_w = state_r ;
				counter_clk_w = counter_clk_r + 1'b1 ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_tempo2: begin
			
			if( i_pause ) begin
				// determine if the state goes to pause
				state_w = S_pause2 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if speed up 
				state_w = S_tempo7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( state_en2 && clk_en2 ) begin
				// time to change state
				state_w = S_tempo1 ; 
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( clk_en2 ) begin
				// determine if it's time to change output number
				state_w = state_r ;
				counter_clk_w = 26'd0 ;
				counter_num_w = counter_num_r + 1'b1;
				o_random_out_w = LFSR_r[3:0];
			end

			else begin
				// just keep counting
				state_w = state_r ;
				counter_clk_w = counter_clk_r + 1'b1 ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_tempo1: begin
			
			if ( i_pause ) begin
				// determine if the state goes to pause
				state_w = S_pause1 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if speed up
				state_w = S_tempo7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else if ( state_en1 && clk_en1 ) begin
				// terminalization -> S_idle
				state_w = S_finished;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = o_random_out_r;
				
			end

			else if ( clk_en1 ) begin
				// determine if it's time to change output number
				state_w = state_r ;
				counter_clk_w = 26'd0 ;
				counter_num_w = counter_num_r + 1'b1;
				o_random_out_w = LFSR_r[3:0];
			end

			else begin
				// just keep counting
				state_w = state_r ;
				counter_clk_w = counter_clk_r + 1'b1 ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_pause7: begin
			if ( i_pause ) begin
				// determine if the state resumes
				state_w = S_tempo7 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if 
				state_w = S_pause7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ; //This Line
			end

			else begin
				// just keep at pause
				state_w = state_r ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end
		end

		S_pause6: begin

			if ( i_pause ) begin
				// determine if the state resumes
				state_w = S_tempo6 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if 
				state_w = S_pause7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else begin
				// just keep at pause
				state_w = state_r ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_pause5: begin

			if ( i_pause ) begin
				// determine if the state resumes
				state_w = S_tempo5 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if 
				state_w = S_pause7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else begin
				// just keep at pause
				state_w = state_r ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_pause4: begin

			if ( i_pause ) begin
				// determine if the state resumes
				state_w = S_tempo4 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if 
				state_w = S_pause7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else begin
				// just keep at pause
				state_w = state_r ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_pause3: begin

			if ( i_pause ) begin
				// determine if the state resumes
				state_w = S_tempo3 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if 
				state_w = S_pause7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else begin
				// just keep at pause
				state_w = state_r ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_pause2: begin
			
			if ( i_pause ) begin
				// determine if the state resumes
				state_w = S_tempo2 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if 
				state_w = S_pause7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else begin
				// just keep at pause
				state_w = state_r ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_pause1: begin
			
			if ( i_pause ) begin
				// determine if the state resumes
				state_w = S_tempo1 ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

			else if ( i_speedup ) begin
				//determine if 
				state_w = S_pause7 ;
				counter_clk_w = 26'd0 ;
				counter_num_w = 5'd0 ;
				o_random_out_w = LFSR_r[3:0] ;
			end

			else begin
				// just keep at pause
				state_w = state_r ;
				counter_clk_w = counter_clk_r ;
				counter_num_w = counter_num_r ;
				o_random_out_w = o_random_out_r ;
			end

		end

		S_finished: begin
			if(i_start) begin  //restart
				state_w = S_tempo5; 
				counter_clk_w = 26'd0;
				counter_num_w = 5'd0;
				o_random_out_w = o_random_out_r;
			end
			else begin
				state_w = state_r;
				counter_clk_w = 26'd0;
				counter_num_w = 5'd0;
				o_random_out_w = o_random_out_r;
			end
		end	

		default: begin

			state_w = S_finished ;
			counter_clk_w = 26'd0 ;
			counter_num_w = 5'd0 ;
			o_random_out_w = 4'd0 ;
			
		end
		
	endcase


end


//============Sequential Circuits================
always_ff @( posedge i_clk or negedge i_rst_n ) begin
	// press reset
	if ( !i_rst_n ) begin 
		state_r <= S_idle ;
		LFSR_r <= 16'b1111_1111_1111_1111 ; // all zeros will get stuck in the same state
		counter_clk_r <= 26'd0 ;
		counter_num_r <= 5'd0 ;
		
		o_random_out_r <= 4'd0 ;
	end

	else begin
		state_r <= state_w ;
		counter_clk_r <= counter_clk_w ;
		counter_num_r <= counter_num_w ;
		LFSR_r <= LFSR_w ;
		o_random_out_r <= o_random_out_w ;
	end
	
end




endmodule
