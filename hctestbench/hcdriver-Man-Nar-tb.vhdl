library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity hcdriver_tb is
end entity hcdriver_tb;

architecture behav of hcdriver_tb is 
 constant FregQ: real :=50.0;
 constant dataout_size: positive := 13;
 signal clock, s_trig, s_echo,s_rst,s_mode,s_start : std_logic := '0';
 signal s_bin: std_logic_vector (dataout_size - 1 downto 0):= (others=>'0');	
 

begin
  -- instantiation of unit under test 
  UUT: entity work.hcdriver(behav)
       generic map(FregQ,dataout_size)
       port map (
       CLK_sys => clock,
       rst  => s_rst,
       mode => s_mode,
       start => s_start,
       bin => s_bin,

       echo => s_echo,
       trig => s_trig
);

hcDummy:entity work.HC_SR04 
            generic map(Line_nRand=>false, Increment=>40 ms)
            port map(s_trig,s_echo);
       
  -- stimuli for clock
  clk_process: process begin
    wait for 10 ns;    
    clock <= not clock;
  end process clk_process;
  
  -- data control
  p1_proc: process begin
	    
	s_rst <= '0';   
	s_mode <= '1';    
    wait for 40 ms;
    report "----Driver value [mm]:" & integer'image(to_integer(unsigned(s_bin)));
    report "--------------------------------";
    
  end process p1_proc;

 
  
  -- end of simulation 
  sim_end_process: process begin
    wait for 240ms;
    assert false
      report "End of simulation at time " & time'image(now)
      severity Failure;
  end process sim_end_process;
  
end architecture behav;