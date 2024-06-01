library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity trig_gen is
   generic ( 
       FREQ_G: real := 10.0 
    );      -- Operating frequency in MHz

    port(
       clk: in std_logic;  
       en: in std_logic;
       rst: in std_logic;
       trig: out std_logic := '0'
    );
end trig_gen;

architecture behav of trig_gen is

constant counter_size: positive := positive( ceil( log2(40000.0 * FREQ_G) ) );
signal trig_end_val: positive := positive( 10.0 * FREQ_G) ;
signal ctr_rst_val: positive := positive( 40000.0 * FREQ_G );
signal s_q: std_logic_vector(counter_size downto 0) := (others=>'0');
signal s_do_trig: std_logic := '0';

begin

  q_cnt:PROCESS (clk)
   BEGIN
       IF rising_edge(clk) THEN
	  

           IF rst='1' THEN
               s_q<=(others=>'0');   
                 s_do_trig <= '0'; 

            elsif unsigned(s_q) >= ctr_rst_val  THEN
               s_q<=(others=>'0'); 
		 s_do_trig <= '0'; 
           
           elsif en='1' THEN
              
	       s_do_trig <= '1';
           
           END IF ;

	   IF s_do_trig = '1' THEN
	      s_q<=s_q+1;
           END IF;
 
      END IF ;
   END PROCESS; 

   q_values:PROCESS (s_q)
   BEGIN
       IF unsigned(s_q) <  trig_end_val+1 AND rst='0' AND s_do_trig = '1' THEN
       trig <= '1';           
       ELSE
       trig <= '0';      
       END IF ;
   END PROCESS; 


end behav;
