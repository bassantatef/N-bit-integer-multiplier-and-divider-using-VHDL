LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all ;

entity mul_div_seq_tb is
generic( N : positive := 4);
end entity mul_div_seq_tb;

architecture mul_div_tb of mul_div_seq_tb is 

component mul_div is
generic( N : positive := 4);
port (
    clk, rst  : in  std_logic                      ;
    A, B      : in  std_logic_vector(N-1 downto 0) ;
    sel       : in  std_logic                      ; -- sel = 0 --> mul, sel = 1 --> div
    enable    : in  std_logic                      ;

    M, R      : out std_logic_vector(N-1 downto 0) ;
    error_bit : out std_logic                      ; -- if B = "0000" : error = 1
    busy_bit  : out std_logic                      ;
    valid_bit : out std_logic 
    );
end component mul_div;

for dut: mul_div use entity work.mul_div (behav);

signal clk_tb:  std_logic ; 
signal rst_tb: std_logic ; 
signal A_tb : std_logic_vector (N-1 DOWNTO 0);
signal B_tb : std_logic_vector (N-1 DOWNTO 0);
signal sel_tb , enable_tb : std_logic ;

signal M_tb : std_logic_vector (N-1 DOWNTO 0);
signal R_tb : std_logic_vector (N-1 DOWNTO 0);
signal error_bit_tb : std_logic ;
signal busy_bit_tb : std_logic ;
signal valid_bit_tb : std_logic ;

begin

	dut: mul_div generic map (N => 4)
		port map (clk => clk_tb , rst => rst_tb , 
		A => A_tb , B => B_tb , sel => sel_tb , 
		enable => enable_tb , M => M_tb , R => R_tb , 
		error_bit => error_bit_tb , busy_bit => busy_bit_tb ,
		valid_bit => valid_bit_tb );
		
	--CLOCK GENERATION T = 20 ps
	clock: process 
		   begin
		   clk_tb <= '0', '1' after 10 ps ;
		   wait for 20 ps ;
		   end process clock ;
		   
	tests: process

		FILE     input_file     : text OPEN READ_MODE IS "inputs.txt" ;
	    VARIABLE line_1         : line ;
    	VARIABLE A_file, B_file : std_logic_vector(N-1 DOWNTO 0) ;
    	VARIABLE enable_file    : std_logic ;
    	VARIABLE sel_file       : std_logic ;
		VARIABLE M_file, R_file : std_logic_vector(N-1 DOWNTO 0) ;
		VARIABLE error_bit_file, valid_bit_file, busy_bit_file : std_logic ;
		VARIABLE message 		: string(35 downto 1) ;

        procedure check(
        	A_in, B_in : std_logic_vector(N-1 DOWNTO 0) ;
			enable_in  : std_logic ;
			sel_in     : std_logic ;
			M_out, R_out : std_logic_vector(N-1 DOWNTO 0) ;
			error_bit_out, valid_bit_out, busy_bit_out : std_logic ;
			message : string)
        
        is begin
        	A_tb <= A_in ; B_tb <= B_in ; enable_tb <= enable_in ; sel_tb <= sel_in ; 
			wait for 20 ps;
			enable_tb <= '0' ;
			wait for 61 ps ;
        	assert M_tb = M_out and R_tb = R_out and error_bit_tb = error_bit_out and valid_bit_tb = valid_bit_out and busy_bit_tb = busy_bit_out 
        	    report message
	    		severity error ;
    
        end procedure check;
			
		begin
		   	rst_tb <= '1';
		   	wait for 10 ps ;
		   	check("XXXX","XXXX",'X','X',"0000","0000",'0','0','0',"Error in Reset ") ;
		   	wait for 20 ps ;
				
		    rst_tb <= '0';
		    -- enable_tb <= '1';
		    
			WHILE NOT endfile (input_file) LOOP
            	READLINE (input_file, line_1)  ;
        	    READ (line_1, A_file) ;
            	READ (line_1, B_file) ;
				READ (line_1, enable_file) ;
            	READ (line_1, sel_file) ;
				READ (line_1, M_file) ;
            	READ (line_1, R_file) ;
				READ (line_1, error_bit_file) ;
            	READ (line_1, valid_bit_file) ;
				READ (line_1, busy_bit_file) ;
            	READ (line_1, message) ;

            	check(A_file, B_file, enable_file, sel_file, M_file, R_file, error_bit_file, valid_bit_file, busy_bit_file, message);
				wait for 10 ps;
        	end LOOP;

			-- report ""
			
			wait;
		end process tests;

end architecture mul_div_tb;
