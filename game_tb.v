`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:13:24 02/24/2022
// Design Name:   game
// Module Name:   C:/Users/Student/Xilinx/lab4_group2_final/game_tb.v
// Project Name:  lab4_group2_final
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: game
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module game_tb;

	// Inputs
	reg clk_in;
	reg RESET;

	// Outputs
	wire [3:0] anode;
	wire [6:0] segs;

	// Instantiate the Unit Under Test (UUT)
	game uut (
		.clk_in(clk_in), 
		.RESET(RESET), 
		.anode(anode), 
		.segs(segs)
	);

	initial begin
		// Initialize Inputs
		clk_in = 0;
		RESET = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

