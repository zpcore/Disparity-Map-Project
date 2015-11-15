 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.all;
use ieee.std_logic_textio.all; 
USE ieee.numeric_std.ALL; 
use ieee.std_logic_textio.all; 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY DispMap_tb IS
 END DispMap_tb;
 
ARCHITECTURE behavior OF DispMap_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DispMap
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         enable : IN  std_logic;
         pixel_in : IN  std_logic_vector(7 downto 0);
         pixel_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal enable : std_logic := '0';
   signal pixel_in : std_logic_vector(7 downto 0) := (others => '0');
 	--Outputs
   signal pixel_out : std_logic_vector(7 downto 0);
   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	 
 	BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DispMap PORT MAP (
          rst => rst,
          clk => clk,
          enable => enable,
          pixel_in => pixel_in,
          pixel_out => pixel_out
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
	 file   infile    : text is in  "imageL.txt";   --declare input file
    variable  inline    : line; --line number declaration
    variable  dataread1    : real;	
	 variable hex : std_logic_vector(7 downto 0);
	 begin  
	 
	  
	  if (not endfile(infile)) then   --checking the "END OF FILE" is not reached.
	  readline(infile, inline);       --reading a line from the file.
		 for j in 1 to 640 loop  
	 		  hread(inline, hex);			 	
			  pixel_in<= hex; 		   
			  wait until rising_edge(clk);
	   end loop;
	  end if;
   end process;
	
	enable<='1';
	rst<='0';
END;
