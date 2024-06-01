-------------------------------------------------
-- CCE 2019
-- HC-SR04 ultrasonic sensor
-- v.1 VHDL-2008
-- v.2 sim resolution hardcoded - Isim:1ns
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity HC_SR04 is
  generic(Increment: time:=40 ms; -- output time interval
          Modelsim: boolean:=True; -- simulator
          Line_nRand: boolean:=false); -- line or random measure 
  port(trig: in std_logic;
       echo: out std_logic);
end;

architecture behav of HC_SR04 is
    -- sensor parameters
    constant SPEED: real:=344.0E3; -- wave mm/sec (~22C deg)
    constant ResReal: real:=1.0e-12; --ps : simulator resolution in real
    constant NO_OBSTACLE: time:= 38 ms;
    constant OUT_OF_RANGE: real:=4.5*1.0E3; -- mm (4m5)
    constant MIN_RANGE: real:= 2.0*1E1; -- mm (2cm)
    constant TOO_CLOSE: time:= 1.0 sec * MIN_RANGE*2.0/SPEED;
    constant TOO_FAR: time:= 1.0 sec * OUT_OF_RANGE*2.0/SPEED;
    constant MIN_TRIGER: time:= 10 us;
    constant INC_SPACE: time:= Increment;

    function time2real(t: time;ResReal: real) return real is
     begin
        return real(t/(ResReal * 1.0 sec)) * ResReal;
    end;

    procedure Gen_Pulse(inc: time; last_space: inout time; signal p:out std_logic) is
        begin
            last_space:=last_space+inc;
            if last_space<TOO_CLOSE then last_space:=TOO_CLOSE; end if;
            if last_space>TOO_FAR then last_space:=NO_OBSTACLE; end if; -- saturation
            p<= '1';
            wait for last_space;
            p<= '0';
            if last_space=NO_OBSTACLE then last_space:=TOO_CLOSE; end if; -- rotate
    end procedure;

    procedure Rand_Pulse(seed1,seed2: inout natural; inc: time; signal p:out std_logic) is
        variable rand: real:=0.0;
        variable last_space: time;
        begin
            uniform(seed1,seed2,rand);
            last_space:=inc*rand;
            if last_space<TOO_CLOSE then last_space:=TOO_CLOSE; end if;
            if last_space>TOO_FAR then last_space:=NO_OBSTACLE; end if; -- saturation
            p<= '1';
            wait for last_space;
            p<= '0';
    end procedure;

    procedure Distance(signal s: in std_logic; signal f: out real; raport_on: boolean:=false;
                       msim: boolean:=true; ResReal: real) is

        variable firstRE, secondRE: time := 1 ns;
        variable f_var,rr: real:=0.0;
     begin
        if msim then rr:=ResReal; else rr:=1.0e-09; end if;
        f_var:=0.0;
        if s='1' then firstRE:=now; 
        wait until s='0'; secondRE:=now; 
        f_var:= time2real(secondRE-firstRE,rr) * SPEED/2.0;
        if raport_on then 
            if (secondRE-firstRE) >= NO_OBSTACLE then
                report "No obstacle!" severity Warning;
            elsif (f_var>OUT_OF_RANGE) or (f_var<MIN_RANGE) then
                report "Out of range!" severity Warning;
            else
                report "Estimated range [mm]= " & integer'image(integer(f_var)) severity Note; 
            end if;
        end if;
        f<=f_var; 
        end if;
    end procedure;

 signal echo_tmp: std_logic:='0';
 signal estimated_range: real:=0.0;

begin
-- synthesis translate off

 SR_behav: process 
    variable last_space: time:= 0 ns;
    variable seed1,seed2: positive:= 13;
 begin
    wait until trig='1'; wait for MIN_TRIGER;
    if trig'last_event<MIN_TRIGER then 
        report "Trig pulse too short!" severity Warning;
    else 
        if Line_nRand then
            Gen_Pulse(INC_SPACE,last_space,echo_tmp); 
        else 
            Rand_Pulse(seed1,seed2,INC_SPACE,echo_tmp); 
        end if;
    end if;
 end process;

   echo<=echo_tmp; -- output

-- check procedure
   Distance(echo_tmp,estimated_range,true,Modelsim,ResReal);

-- synthesis translate on 
end architecture;