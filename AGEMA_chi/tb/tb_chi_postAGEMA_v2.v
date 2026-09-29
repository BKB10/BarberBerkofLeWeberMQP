/*
 * Des: Functional verification of POST-AGEMA_FPGA netlist vs chi.v golden model
 * DUT: chi_GHPCLL__d1.v
 * Author: Huy Le - Sep 26th, 2026
 * Note: Pure Verilog-2001 implementation with golden pipeline matching
 */

`timescale 1ns/1ps

module tb_chi_GHPCLL__d1;

  parameter STATE_W  = 1600;
  parameter FRESH_W  = 12800;
  parameter CLK_PER  = 10;
  parameter NUM_TEST = 100;

  reg                clk;
  reg  [STATE_W-1:0] state_in1;
  reg  [STATE_W-1:0] s0, s1;
  reg  [FRESH_W-1:0] Fresh;

  wire [STATE_W-1:0] golden_out;
  wire [STATE_W-1:0] mo0, mo1;
  wire [STATE_W-1:0] masked_out = mo0 ^ mo1;

  // Pipeline register to match 1-clock cycle latency of GHPCLL
  reg  [STATE_W-1:0] golden_pipe;

  integer i, errors = 0;

  // Golden Model Instantiation
  chi golden (
    .state_in1(state_in1),
    .state_out1(golden_out)
  );

  // Post-AGEMA Flattened Netlist DUT
  chi_GHPCLL__d1 dut (
    .clk           (clk),
    .state_in1_s0  (s0),
    .state_in1_s1  (s1),
    .Fresh         (Fresh),
    .state_out1_s0 (mo0),
    .state_out1_s1 (mo1)
  );

  // Clock Generator
  initial clk = 0;
  always #(CLK_PER/2) clk = ~clk;

  // Align golden model latency with 1-cycle GHPCLL delay
  always @(posedge clk) begin
    golden_pipe <= golden_out;
  end

  // Randomization Tasks
  task randomize_reg;
    output reg [STATE_W-1:0] target;
    integer j;
    begin
      for (j = 0; j < STATE_W; j = j + 32)
        target[j+:32] = $random;
    end
  endtask

  task randomize_fresh;
    output reg [FRESH_W-1:0] target;
    integer j;
    begin
      for (j = 0; j < FRESH_W; j = j + 32)
        target[j+:32] = $random;
    end
  endtask

  // Stimulus & Verification Loop
  initial begin
    state_in1   = 0;
    s0          = 0;
    s1          = 0;
    Fresh       = 0;
    golden_pipe = 0;

    #(CLK_PER * 2);

    @(negedge clk);
    for (i = 0; i <= NUM_TEST; i = i + 1) begin
      // Apply new randomized inputs on negedge
      randomize_reg(state_in1);
      randomize_reg(s0);
      s1 = state_in1 ^ s0;
      randomize_fresh(Fresh);

      // Settle and evaluate post posedge
      @(posedge clk);
      #1;

      // Skip cycle 0 while pipeline fills
      if (i > 0) begin
        $display("\n---- Vector %0d @ %0t ----", i - 1, $time);
        $display("  state_in1        = %h", state_in1);
        $display("  s0               = %h", s0);
        $display("  s1               = %h", s1);
        $display("  Fresh            = %h", Fresh);
        $display("  golden           = %h", golden_pipe);
        $display("  masked (=mo0^mo1)= %h", masked_out);

        if (masked_out !== golden_pipe) begin
          errors = errors + 1;
          $display("########## MISMATCH @ %0t: exp=%h got=%h ##########", $time, golden_pipe, masked_out);
        end else begin
          $display("############### RESULT = PASS ###############");
        end
      end
      @(negedge clk);
    end

    if (errors == 0)
      $display("\n ----- ALL %0d TESTS PASSED -----", NUM_TEST);
    else
      $display("\n %0d MISMATCHES - %0d TESTS PASSED", errors, (NUM_TEST - errors));

    $finish;
  end

endmodule
