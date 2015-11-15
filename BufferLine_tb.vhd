library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
USE ieee.numeric_std.ALL; 
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY BufferLine_tb IS
END BufferLine_tb;
 
ARCHITECTURE behavior OF BufferLine_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BufferLine
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         din : IN  std_logic_vector(7 downto 0);
         wr_en : IN  std_logic;
         rd_en : IN  std_logic;
         dout : OUT  std_logic_vector(7 downto 0);
         full : OUT  std_logic;
         empty : OUT  std_logic;
         data_count : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal din : std_logic_vector(7 downto 0) := (others => '0');
   signal wr_en : std_logic;
   signal rd_en : std_logic := '0';

 	--Outputs
   signal dout : std_logic_vector(7 downto 0);
   signal full : std_logic;
   signal empty : std_logic;
   signal data_count : std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BufferLine PORT MAP (
          clk => clk,
          rst => rst,
          din => din,
          wr_en => wr_en,
          rd_en => rd_en,
          dout => dout,
          full => full,
          empty => empty,
          data_count => data_count
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
		rst<='0';
		din<= std_logic_vector(unsigned(din)+1);
		wr_en<='1';
		
      -- insert stimulus here 

      wait;
   end process;

END;
