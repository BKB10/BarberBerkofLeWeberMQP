/*
	* Des: This tb is SOLELY for FUNCTIONAL VERIFICATION of the POST-AGEMA_FGPA netlist, using chi.v as the golden model
	* DUT: chi_xilinx_netlists_GHPCLL__d1.v
	* Author: Huy Le - Sep 26th, 2026
	* NOTE 1: This tb uses a LUT3_GHPC.v module to sort of mimic LUT3_GHPC FUNCTIONALLY, since none explicit definition found (LOL)
	* NOTE 2: "Fresh" mask in randomly generated with a constraint to fill all the bits
*/

`timescale 1ns/1ps

// Macro

module tb_chi_postAGEMA;

  reg [1599:0] state_in1;
  reg [1599:0] s0, s1;
  reg [12799:0] Fresh;
  reg clk = 0;
  wire [1599:0] golden_out;
  wire [1599:0] mo0, mo1;

  // chi.v - GOLDEN MODEL
  chi golden (
	  .state_in1(state_in1), 
	  .state_out1(golden_out)
  );
  
  // Post-AGEMA, flattened netlist - DUT
  chi_GHPCLL__d1 dut (
    .state_in1_s0(s0), 
    .state_in1_s1(s1), 
    .clk(clk),
    .Fresh(Fresh), 
    .state_out1_s0(mo0), 
    .state_out1_s1(mo1)
  );

  // CLK
  always #5 clk = ~clk;

  // Other vars
  integer i, errors = 0;
  reg [1599:0] masked_out;
  integer NUM_TEST = 100;

  task randomize_reg;
  	output reg [1599:0] target;
  	integer j;
  	begin
    		for (j = 0; j < 1600; j = j + 32)
      			target[j+:32] = $random;
  	end
  endtask

  task randomize_fresh;
  	output reg [12799:0] target;
  	integer j;
  	begin
    		for (j = 0; j < 12800; j = j + 32)
      			target[j+:32] = $random;
  	end
  endtask
  	
  // Main task in main loop
  task run_vector;
    begin
/*
      state_in1 = {$random, $random, $random, $random, $random,
                   $random, $random, $random, $random, $random,
                   $random, $random, $random, $random, $random,
                   $random, $random, $random, $random, $random,
                   $random, $random, $random, $random, $random};
      s0 = {$random,$random,$random,$random,$random,$random,$random,$random,
            $random,$random,$random,$random,$random,$random,$random,$random,
            $random,$random,$random,$random,$random,$random,$random,$random,$random};
*/
      randomize_reg(state_in1);
      randomize_reg(s0);
      s1 = state_in1 ^ s0;
      @(negedge clk); 			// settle inputs before edge
//      Fresh = {$random}; 		// pseudo-random per call; repeat if wider randomness needed
	randomize_fresh(Fresh);

      // Since DUT is GHPCLL --> 1 clk cycle delay
      @(posedge clk);   // 1 register stage
      #1;

      // Golden v. DUT comparison
      masked_out = mo0 ^ mo1;

      $display("\n---- Vector %0d @ %0t ----", i, $time);
      $display("  state_in1 	  = %h", state_in1);
      $display("  s0        	  = %h", s0);
      $display("  s1              = %h", s1);
      $display("  Fresh           = %h", Fresh);
      $display("  golden          = %h", golden_out);
      $display("  masked (=s0^s1) = %h", masked_out);

      if (masked_out !== golden_out) begin
        errors = errors + 1;
        $display("########## MISMATCH @ %0t: exp=%h got=%h ##########", $time, golden_out, masked_out);
      end else
	$display("############### RESULT = PASS ###############");
    end
  endtask

  //------------------------------- MAIN SEQUENCE LOOP ------------------------------
  initial begin
    Fresh = 0; s0 = 0; s1 = 0; state_in1 = 0;

    @(negedge clk);
    for (i = 0; i < NUM_TEST; i = i + 1)
      run_vector;
    if (errors == 0) $display("\n ----- ALL %0d TESTS PASSED -----", NUM_TEST);
    else $display("%0d MISMATCHES - %0d TESTS PASSED", errors, (NUM_TEST - errors));
    $finish;
  end
endmodule
