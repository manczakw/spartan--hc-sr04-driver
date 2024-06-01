library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;




entity echo_counter is
   generic ( 
       FREQ_G: real := 10.0 
    );      -- Operating frequency in MHz

    port(
       clk: in std_logic;  
       echo: in std_logic;
       rst: in std_logic;
       dist: out std_logic_vector (12 downto 0):= (others=>'0')
    );
end echo_counter;

architecture behav of echo_counter is

constant counter_size: positive := positive( ceil( log2(38000.0 * FREQ_G) ) );

constant one_mm_val: positive := positive( 5.8 * FREQ_G );
signal s_q: std_logic_vector(counter_size downto 0) := (others=>'0');
signal s_dist: std_logic_vector (12 downto 0):= (others=>'0');

begin

  q_cnt:PROCESS (clk)
   BEGIN
       IF rising_edge(clk) THEN
	  

           IF rst='1' THEN
               s_q<=(others=>'0');
	       s_dist <= (others=>'0');       

           elsif echo='1' THEN
               s_q<=s_q+1;

	       IF unsigned(s_q) = one_mm_val -1  THEN
		s_q<=(others=>'0'); 
		
		elsif unsigned(s_q) = one_mm_val - 2  THEN
		
		s_dist <= s_dist + 1;
		END IF;
           
           END IF ;
	dist <= s_dist;
      END IF ;
   END PROCESS; 

   


end behav;
