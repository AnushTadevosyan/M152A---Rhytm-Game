`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:03:53 02/24/2022 
// Design Name: 
// Module Name:    game 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module game(
	input clk_in,
	input START,
	input RESET,
	output [3:0] anode,
	output [6:0] segs
    );
	 
	 // Clocks
    wire clk_1Hz;
    wire clk_2Hz;
    wire clk_fast;
	 
	 //debounced buttons
	 wire rst;
	 wire game_begin;
	 
	 // Display segments
    wire [6:0] segs0;
    wire [6:0] segs1;
    wire [6:0] segs2;
    wire [6:0] segs3;
	 
	 // Asynchronous reset
    arst reseter(
        .clk_in(clk_in),
        .btnR(RESET),
        .rst(rst)
    );
	 
	 // Break up the clock into its different speeds.
    clk_gen c_gen(
        .clk_in(clk_in),
        .rst(rst),
        .clk_1Hz(clk_1Hz),
        .clk_2Hz(clk_2Hz),
		  .clk_fast(clk_fast)
    );
	 
	 debounce start(
        .clk_in(clk_in),
        .clk_fast(clk_fast),
        .rst(rst),
        .button_in(START),
        .button_out(game_begin)
    );
	 
	 // Toggle start
    reg start_reg = 0;
    always @ (posedge clk_in) begin
        if (rst) begin
            start_reg <= 0;
        end
        else if (game_begin) begin
            start_reg <= ~start_reg;
        end
        else begin
            start_reg <= start_reg;
        end
    end
	
	// Handle which digit displays what
    digit_to_seven_seg dts(
        .clk_in(clk_in),
        .rst(rst),
        .segs0(segs0),        // XX:XY
        .segs1(segs1),        // XX:YX
        .segs2(segs2),        // XY:XX
        .segs3(segs3),         // YX:XX
		  .segs(segs),
		  .anode(anode)
    );

endmodule

module clk_gen(
	input clk_in,
	input rst,
	output reg clk_1Hz,
   output reg clk_2Hz,
	output reg clk_fast
);
	reg [25:0] count_1Hz;   // Large enough to hold 50,000,000 states
   reg [24:0] count_2Hz;   // Large enough to hold 25,000,000 states
	reg [16:0] count_fast;  // Large enough to hold 100,000 states
	
	//1 Hz clock
	always @(posedge clk_in) begin
        if (rst) begin
            count_1Hz <= 0;
            clk <= 0;
        end
       
        // 50,000,000 states with 50% duty = divide by 100,000,000 clock
        else if (count_1Hz == 26'd49_999_999) begin // 49_999_999
        // else if (count_1Hz == 26'd490) begin // 490 for simulation
            clk_1Hz <= ~clk_1Hz;
            count_1Hz <= 0;
        end

        // Increment count
        else begin
            count_1Hz <= count_1Hz + 1'd1;
        end
    end
	 
	 //2 Hz clock
	 always @(posedge clk_in) begin
        // Reset
        if (rst) begin
            count_2Hz <= 0;
            clk_2Hz <= 0;
        end

        // 25,000,000 states with 50% duty = divide by 50,000,000 clock
        else if (count_2Hz == 25'd24_999_999) begin // 24_999_999
        // else if (count_2Hz == 25'd240) begin // 240 for simulation
            clk_2Hz <= ~clk_2Hz;
            count_2Hz <= 0;
        end
        
        // Increment count
        else begin
            count_2Hz <= count_2Hz + 1'd1;
        end
    end
	 
	 // fast clock
    always @(posedge clk_in) begin
        // Reset
        if (rst) begin
            count_fast <= 0;
            clk_fast <= 0;
        end

        // 100,000 states with 50% duty = divide by 200,000 clock
        else if (count_fast == 19'd199_999) begin // 199_999
        // else if (count_fast == 19'd19) begin // 19 for simulation
            clk_fast <= ~clk_fast;
            count_fast <= 0;
        end
        
        // Increment count
        else begin
            count_fast <= count_fast + 1'd1;
        end
    end
endmodule

module arst(
    input clk_in,
    input btnR,
    output wire rst
    );

    wire arst_i;
    reg [1:0] arst_ff;
    assign arst_i = btnR;
    assign rst = arst_ff[0];
    
    always @ (posedge clk_in, posedge arst_i)
        if (arst_i) begin
            arst_ff <= 2'b11;
        end

        else begin
            arst_ff <= {1'b0, arst_ff[1]};
        end
endmodule

module debounce(
    input clk_in,
    input clk_fast,
    input rst,
    input button_in,
    output wire button_out
    );

    wire btn_i;
    reg [2:0] step_d;
    assign btn_i = button_in;
    assign button_out = step_d[0];

    always @ (posedge clk_in) begin
        if (rst) begin
            step_d[2:0]  <= 0;
        end
        else if (clk_fast) begin
            if (btn_i) begin
                step_d <= 3'b111;
            end
            else begin 
                step_d[2:0]  <= {btn_i, step_d[2:1]};
            end
        end
    end
endmodule

module digit_to_seven_seg(
    input clk_in,
    input rst,
    output reg [6:0] segs0,
    output reg [6:0] segs1,
    output reg [6:0] segs2,
    output reg [6:0] segs3,
	 output reg [6:0] segs,
	 output reg [3:0] anode
    );

	reg [1:0] count = 0;
	always @(posedge clk_in, posedge rst) begin 
	 
		count <= count + 1'd1;
		 
		if (rst) begin
			segs0 <= 7'b1111111;
			segs1 <= 7'b1111111;
			segs2 <= 7'b1111111;
			segs3 <= 7'b1111111;
		end
		else if (count == 1'd0) begin
			 anode <= 4'b1110;
			 segs0 <= 7'b0000111;
			segs1 <= 7'b1111111;
			segs2 <= 7'b1111111;
			segs3 <= 7'b1111111;
			 segs <= segs0;
		end
		else if (count == 1'd1) begin
			 anode <= 4'b1101;
			 segs0 <= 7'b1111111;
			segs1 <= 7'b0011101;
			segs2 <= 7'b1111111;
			segs3 <= 7'b1111111;
			 segs <= segs1;
		end
		else if (count == 2'd2) begin
			 anode <= 4'b1011;
			 segs0 <= 7'b1111111;
			segs1 <= 7'b1111111;
			segs2 <= 7'b1100011;
			segs3 <= 7'b1111111;
			 segs <= segs2;
		end
		else begin
			 anode <= 4'b0111;
			 segs0 <= 7'b1111111;
			segs1 <= 7'b1111111;
			segs2 <= 7'b1111111;
			segs3 <= 7'b0110001;
			 segs <= segs3;
		end
	end
endmodule
