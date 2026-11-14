-- LUT3_GHPC: wrapper with the exact interface the post-AGEMA_FPGA netlist instantiates.
-- NOT the authors' cell (unavailable). Built from the authors' GHPC gadget VHDL + one INIT patch.
-- Supports GHPC (low_latency=0) and GHPCLL (low_latency=1), 8 fresh bits.
-- Port bundles are {share1, share0}.

-- Changed entity adn arch. name from "LUT3_GHPC" to "LUT3_GHCP_vhdl" for tb purpose

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LUT3_GHPC_vhdl is
   Generic (
      INIT        : integer := 0;
      low_latency : integer := 1;
      pipeline    : integer := 1;
      in_size     : integer := 3;
      out_size    : integer := 1);
   Port (
      I0, I1, I2 : in  std_logic_vector(1 downto 0);
      clk        : in  std_logic;
      r          : in  std_logic_vector(out_size*(1+low_latency*(2**in_size-1))-1 downto 0);
      O          : out std_logic_vector(1 downto 0));
end LUT3_GHPC_vhdl;

architecture Structural of LUT3_GHPC_vhdl is
   signal x0, x1 : std_logic_vector(2 downto 0);
   signal o0, o1 : std_logic_vector(0 downto 0);
begin
   assert low_latency = 0 or low_latency = 1
      report "LUT3_GHPC: low_latency must be 0 (GHPC) or 1 (GHPCLL)" severity failure;

   x0 <= I2(0) & I1(0) & I0(0);
   x1 <= I2(1) & I1(1) & I0(1);

   g: entity work.GHPC_Gadget_LUT3
      generic map (
         in_size     => 3,
         out_size    => 1,
         low_latency => low_latency,    -- ← was hardcoded 1
         pipeline    => pipeline,
         INIT        => std_logic_vector(to_unsigned(INIT, 8)))
      port map (in0 => x0, in1 => x1, r => r, clk => clk, out0 => o0, out1 => o1);

   O <= o1(0) & o0(0);
end Structural;
