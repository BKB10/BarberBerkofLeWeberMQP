/*
- 	Des: This tb is SOLELY for FUNCTIONAL VERIFICATION of the POST-AGEMA_FGPA netlist, using chi.v as the golden model
- 	DUT: chi_xilinx_netlists_GHPCLL__d1.v
- 	Author: Huy Le - Sep 26th, 2026
-   Last Updated: Huy Le - Oct 19th, 2026
- 	NOTE 1: This tb uses a LUT3_GHPC.v module to sort of mimic LUT3_GHPC FUNCTIONALLY, since none explicit definition found (LOL)
- 	NOTE 2: "Fresh" mask in randomly generated with a constraint to fill all the bits
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

  //--- chi.v - GOLDEN MODEL ---//
  chi golden (
    .state_in1(state_in1), 
    .state_out1(golden_out)
  );
  
  //--- Post-AGEMA, flattened netlist - DUT ---//
  chi_GHPCLL__d1 dut (
    .state_in1_s0(s0), 
    .state_in1_s1(s1), 
    .clk(clk),
    .Fresh(Fresh), 
    .state_out1_s0(mo0), 
    .state_out1_s1(mo1)
  );

  //--- CLK ---//
  always #5 clk = ~clk;

  //--- Other vars ---//
  integer i, j = 0; 
  
  // Chi stuff
  reg [1599:0] masked_out;
  integer NUM_TEST = 200;
  
  // Error stuff
  integer errors = 0;
  reg [31:0] fail_vec [0:99];
  integer fail_count;

  //--- Task randomize_reg ---//
  task randomize_reg;
    output reg [1599:0] target;
    integer j;
    begin
        for (j = 0; j < 1600; j = j + 32)
            target[j+:32] = $random;
    end
  endtask

  //--- Task randomize_fresh ---//
  task randomize_fresh;
    output reg [12799:0] target;
    integer j;
    begin
        for (j = 0; j < 12800; j = j + 32)
            target[j+:32] = $random;
    end
  endtask
    
  //--- Main task in main loop ---//
  task run_vector;
    input integer vec_idx;
    begin
      randomize_reg(state_in1);
      randomize_reg(s0);
      s1 = state_in1 ^ s0;
      @(negedge clk);           // settle inputs before edge
      randomize_fresh(Fresh);

      // Since DUT is GHPCLL --> 1 clk cycle delay
      @(posedge clk);   // 1 register stage
      #1;

      // Golden v. DUT comparison
      masked_out = mo0 ^ mo1;

      // Error recording
      if (masked_out !== golden_out) begin
        errors = errors + 1;
        fail_vec[fail_count] = vec_idx;
        fail_count = fail_count + 1;

        $display("\n########## MISMATCH @ Vector %0d (Time: %0t) ##########", vec_idx, $time);
        $display("  state_in1       = %h", state_in1);
        $display("  s0              = %h", s0);
        $display("  s1              = %h", s1);
        $display("  Fresh           = %h", Fresh);
        $display("  golden (exp)    = %h", golden_out);
        $display("  masked (=s0^s1) = %h", masked_out);
      end
    end
  endtask

  //------------------------------- MAIN SEQUENCE LOOP ------------------------------//

    //--- MAIN LOOP ---//
    initial begin
        Fresh = 0; s0 = 0; s1 = 0; state_in1 = 0;
        fail_count = 0;
        errors = 0;
    
    // Init fail_vec
    for (j = 0; j < 100; j = j + 1)
        fail_vec[j] = 0;
    
        //--- Drive Stimulus + Getting Output ---//
        @(negedge clk);
        for (i = 0; i < NUM_TEST; i = i + 1) begin
            run_vector(i);
        end
    
        //--- Results Tally-up ---//
        if (errors == 0) begin
            $display("\n----- ALL %0d TESTS PASSED! YAY! -----\n", NUM_TEST);
        end else begin
            $display("\n ----- TEST FAILED: %0d MISMATCH(ES) ----- \n", fail_count);
            for (j = 0; j < fail_count; j = j + 1)
                $display("\n--- Failed vector index: %0d --- \n", fail_vec[j]);
        end
        $finish;
    end    
endmodule