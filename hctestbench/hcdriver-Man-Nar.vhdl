

-------------------------------------------------
-- CCE 2019
-- HC-SR04 ultrasonic sensor testbench
-- v.1 VHDL-2008
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;
use ieee.math_real.all;


entity hcdriver is
    generic ( 
       F_CLK: real := 50.0;
	    N: positive := 13
    );     

    port(
       CLK_sys: in std_logic;
       rst: in std_logic;   --rst     
       mode: in std_logic;  --mode
       start: in std_logic; --start
       bin: out std_logic_vector (N-1 downto 0):= (others=>'0');	
-------------------------------------------------------	
       echo: in std_logic; --echo
       trig: out std_logic --trig

    );
end hcdriver;



architecture behav of hcdriver is

 
 signal s_en:  std_logic:='0'; 
 signal s_echo_counter_rst:  std_logic:='0';
 signal s_trig: std_logic:='0';
 signal s_echo: std_logic:='0';
    
 
 
begin

s_en <= (start or mode);


gen:entity work.trig_gen 
            generic map(FREQ_G=>F_CLK)
            port map(CLK_sys,s_en,rst,s_trig);

trig <= s_trig;
s_echo <= echo;



s_echo_counter_rst <= (rst or s_trig);



echoent:entity work.echo_counter 
            generic map(FREQ_G=>F_CLK)
            port map(clk_sys, s_echo, s_echo_counter_rst,bin);
		
end behav;