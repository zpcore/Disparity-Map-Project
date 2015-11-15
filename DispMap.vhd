library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
USE ieee.numeric_std.ALL; 

entity DispMap is
  port (rst : in  std_ulogic;      
        clk : in  std_ulogic;     
        enable : in  std_ulogic;		  
        pixel_in : in  std_logic_vector(7 downto 0);
        census_L: out std_logic_vector(24 downto 0);
		  valid : out  std_ulogic
		  );		  
end DispMap;

architecture Behavioral of DispMap is
  
  constant Width : integer := 633; -- Image width
	-- active window pixels 5x5 pixels (8 bits) 
  type pixels_row is array (0 to 4) of std_logic_vector(7 downto 0);
  signal P0: pixels_row;
  signal P1: pixels_row;
  signal P2: pixels_row;
  signal P3: pixels_row;
  signal P4: pixels_row;
	--END

	-- FIFOs' signals
  signal din1,din2,din3,din4 : std_logic_vector(7 downto 0):= (others => '0'); -- Input signals
  signal dout1,dout2,dout3,dout4 : std_logic_vector(7 downto 0); -- Output signals
  signal data_count1,data_count2,data_count3,data_count4: std_logic_vector(9 downto 0); -- datacount signal 
  signal rd_en1,rd_en2,rd_en3,rd_en4 : std_logic := '0'; -- read signal
  signal wr_en1,wr_en2,wr_en3,wr_en4 : std_logic := '0'; -- write signal
	-- END 

  signal x : std_logic_vector(7 downto 0):= (others => '0');
  signal X_p : std_logic_vector(9 downto 0):= (others => '0');
  signal Y_p : std_logic_vector(9 downto 0):= (others => '0');

  signal valid_s : std_logic := '0'; -- valid window to start processing 

  
  
  -- FIFO component declaration
  COMPONENT BufferLine
   PORT (
		 clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_en : IN STD_LOGIC;
		 rd_en : IN STD_LOGIC;
		 dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 full : OUT STD_LOGIC;
		 empty : OUT STD_LOGIC;
		 data_count : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
   END COMPONENT;
	
	
	 
begin

execution: process(clk, rst, pixel_in) 
	begin
    if rst = '1' then -- reset low  
	 
    elsif rising_edge(clk) then
	 
		if enable = '1' then
		
		 P0(0) <= pixel_in;	P0(1) <= P0(0);	P0(2) <= P0(1);	P0(3) <= P0(2); 	P0(4) <= P0(3);		
		 P1(0) <= dout1;		P1(1) <= P1(0);	P1(2) <= P1(1);	P1(3) <= P1(2); 	P1(4) <= P1(3);		
		 P2(0) <= dout2;		P2(1) <= P2(0);	P2(2) <= P2(1);	P2(3) <= P2(2); 	P2(4) <= P2(3);		
		 P3(0) <= dout3;		P3(1) <= P3(0);	P3(2) <= P3(1);	P3(3) <= P3(2); 	P3(4) <= P3(3);
		 P4(0) <= dout4;		P4(1) <= P4(0);	P4(2) <= P4(1);	P4(3) <= P4(2); 	P4(4) <= P4(3);
		 	
	   if((wr_en1='0') or ((wr_en2='0')and (rd_en1='1')) or ((wr_en3='0')and (rd_en2='1')) or ((wr_en4='0')and (rd_en3='1')) or ((valid_s='0')and (rd_en4='1'))) then
		  x <= std_logic_vector(unsigned(x)+1);
		end if; 	
		
		if((to_integer(unsigned(x))= 4) and (wr_en1='0')) then
				wr_en1<= '1';				
		  	   x <= X"00";
		 elsif ((wr_en2='0')and (rd_en1='1') and((to_integer(unsigned(x))= 4))) then
				wr_en2<= '1';				
		  	   x <= X"00";
		 elsif ((wr_en3='0')and (rd_en2='1') and((to_integer(unsigned(x))= 4))) then
				wr_en3<= '1';				
		  	   x <= X"00";			 
		 elsif ((wr_en4='0')and (rd_en3='1') and((to_integer(unsigned(x))= 4))) then
				wr_en4<= '1';				
		  	   x <= X"00";	 
		 elsif ((rd_en4='1') and((to_integer(unsigned(x))= 8))) then
		 	   valid_s<= '1';				
		  	   x <= X"00";	 
					
		 end if;

		 if(to_integer(unsigned(data_count1))= Width) then rd_en1 <='1';    end if;
		 if(to_integer(unsigned(data_count2))= Width) then rd_en2 <='1';	  end if;		 
		 if(to_integer(unsigned(data_count3))= Width) then rd_en3 <='1';	  end if;
		 if(to_integer(unsigned(data_count4))= Width) then rd_en4 <='1';	  end if;


     -- Update the x and y positions 
 	    X_p <= std_logic_vector(unsigned(X_p)+1);						 
	    if(to_integer(unsigned(X_p))= 639) then 		 
		 	X_p <= B"0000000000";  
			Y_p<= std_logic_vector(unsigned(Y_p)+1); 
		end if;
	-- END
	 end if; 
	 end if; 	
  
end process;
	
	din1 <= P0(4);
	din2 <=P1(4);	
	din3 <=P2(4);
	din4 <=P3(4);
   valid <=valid_s;
---------------------------------------------------------------------------------------------------------

Census_T: process(clk, rst, valid_s)  
begin
    if rst = '1' then -- reset low  
	 
    elsif rising_edge(clk) then
	 
		if valid_s = '1' then 
			 
	   -- synthesizable for loop
		for i in 0 to 4 loop
	     if(P0(i)> P2(2)) then  Census_L(0 +5*i)<= '1'; else Census_L(0 +5*i)<= '0'; end if;	 
		   if(P1(i)> P2(2)) then  Census_L(1 +5*i)<= '1'; else Census_L(1 +5*i)<= '0'; end if;	 
			  if(P2(i)> P2(2)) then  Census_L(2 +5*i)<= '1'; else Census_L(2 +5*i)<= '0'; end if;	 
			  if(P3(i)> P2(2)) then  Census_L(3 +5*i)<= '1'; else Census_L(3 +5*i)<= '0'; end if;	 
			  if(P4(i)> P2(2)) then  Census_L(4 +5*i)<= '1'; else Census_L(4 +5*i)<= '0'; end if;			  
		 end loop;
	  
--	  if(P0(0)> P2(2)) then  Census_L(0)<= '1'; else Census_L(0)<= '0'; end if;	 
--	  if(P0(1)> P2(2)) then  Census_L(1)<= '1'; else Census_L(1)<= '0'; end if;	 
--	  if(P0(2)> P2(2)) then  Census_L(2)<= '1'; else Census_L(2)<= '0'; end if;	 
--	  if(P0(3)> P2(2)) then  Census_L(3)<= '1'; else Census_L(3)<= '0'; end if;	 
--	  if(P0(4)> P2(2)) then  Census_L(4)<= '1'; else Census_L(4)<= '0'; end if;
--	  
--	  if(P1(0)> P2(2)) then  Census_L(5)<= '1'; else Census_L(5)<= '0'; end if;	 
--	  if(P1(1)> P2(2)) then  Census_L(6)<= '1'; else Census_L(6)<= '0'; end if;	 
--	  if(P1(2)> P2(2)) then  Census_L(7)<= '1'; else Census_L(7)<= '0'; end if;	 
--	  if(P1(3)> P2(2)) then  Census_L(8)<= '1'; else Census_L(8)<= '0'; end if;	 
--	  if(P1(4)> P2(2)) then  Census_L(9)<= '1'; else Census_L(9)<= '0'; end if;	    
--	  
--	  if(P2(0)> P2(2)) then  Census_L(10)<= '1'; else Census_L(10)<= '0'; end if;	 
--	  if(P2(1)> P2(2)) then  Census_L(11)<= '1'; else Census_L(11)<= '0'; end if;	  
--	  if(P2(3)> P2(2)) then  Census_L(12)<= '1'; else Census_L(12)<= '0'; end if;	 
--	  if(P2(4)> P2(2)) then  Census_L(13)<= '1'; else Census_L(13)<= '0'; end if;			
--
--	  if(P3(0)> P2(2)) then  Census_L(14)<= '1'; else Census_L(14)<= '0'; end if;	 
--	  if(P3(1)> P2(2)) then  Census_L(15)<= '1'; else Census_L(15)<= '0'; end if;	 
--	  if(P3(2)> P2(2)) then  Census_L(16)<= '1'; else Census_L(16)<= '0'; end if;	 
--	  if(P3(3)> P2(2)) then  Census_L(17)<= '1'; else Census_L(17)<= '0'; end if;	 
--	  if(P3(4)> P2(2)) then  Census_L(18)<= '1'; else Census_L(18)<= '0'; end if;	
--	  
--	  if(P4(0)> P2(2)) then  Census_L(19)<= '1'; else Census_L(19)<= '0'; end if;	 
--	  if(P4(1)> P2(2)) then  Census_L(20)<= '1'; else Census_L(20)<= '0'; end if;	 
--	  if(P4(2)> P2(2)) then  Census_L(21)<= '1'; else Census_L(21)<= '0'; end if;	 
--	  if(P4(3)> P2(2)) then  Census_L(22)<= '1'; else Census_L(22)<= '0'; end if;	 
--	  if(P4(4)> P2(2)) then  Census_L(23)<= '1'; else Census_L(23)<= '0'; end if;	
--	  
--	  

		end if;		
	end if;	
		
		

end process;



	
Line1 : BufferLine port map
			 (	clk   => clk,
			   rst   => rst,
				din   => din1,
				wr_en => wr_en1, 
				rd_en => rd_en1, 
				dout  => dout1,
				data_count => data_count1
			  ); 
			  
Line2 : BufferLine port map
			 (	clk   => clk,
			   rst   => rst,
				din   => din2,
				wr_en => wr_en2, 
				rd_en => rd_en2, 
				dout  => dout2,
				data_count => data_count2
			  ); 
			  			  
Line3 : BufferLine port map
			 (	clk   => clk,
			   rst   => rst,
				din   => din3,
				wr_en => wr_en3, 
				rd_en => rd_en3, 
				dout  => dout3,
				data_count => data_count3
			  ); 	
Line4 : BufferLine port map
			 (	clk   => clk,
			   rst   => rst,
				din   => din4,
				wr_en => wr_en4, 
				rd_en => rd_en4, 
				dout  => dout4,
				data_count => data_count4
			  ); 			  
end Behavioral;

