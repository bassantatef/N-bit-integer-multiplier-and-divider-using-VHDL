LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all ;
-- USE ieee.numeric_bit.all;

entity mul_div is
generic( N : positive := 4);
port(
    clk, rst  : in  std_logic                      ;
    A, B      : in  std_logic_vector(N-1 downto 0) ;
    sel       : in  std_logic                      ; -- sel = 0 --> mul, sel = 1 --> div
    enable    : in  std_logic                      ;

    M, R      : out std_logic_vector(N-1 downto 0) ;
    error_bit : out std_logic                      ; -- if B = "0000" : error = 1
    busy_bit  : out std_logic                      ;
    valid_bit : out std_logic 
    );
end entity mul_div;

architecture behav of mul_div is
begin 
    process(clk, rst) is
        variable counter : integer range 0 to N := 0 ;

        variable B_temp  : std_logic_vector(N downto 0) := (others => '0') ; 
        variable B_comp  : std_logic_vector(N downto 0) := (others => '0') ;

        variable T       : std_logic_vector(N downto 0)   := (others => '0') ;
        variable Q       : std_logic_vector(N-1 downto 0) := (others => '0') ;
		
		--Multiplier
		variable cnt     : unsigned(N-1 downto 0):= (others => '0');
		variable acc     : std_logic_vector(2*N downto 0);

    begin
        if rst = '1' then
            B_temp    := (others => '0') ;
            B_comp    := (others => '0') ;
			T      	  := (others => '0') ;
            Q         := (others => '0') ;
            M         <= (others => '0') ;
            R         <= (others => '0') ;
            counter   :=  0  ;
            error_bit <= '0' ;
            busy_bit  <= '0' ;
            valid_bit <= '0' ;
			
			acc       :=  (others => '0') ;
			cnt       :=  (others => '0') ;

        elsif clk = '1' and clk'event then
            if sel = '1' then                ----- Division -----  
			    if B = "0000" then 
			    	error_bit <= '1' ;
					valid_bit <= '0' ;
                    busy_bit  <= '0' ;
					M         <= (others => '0') ; --i put them with zeros in order to be as combinational architecture
					R         <= (others => '0') ;
			    else
                    error_bit <= '0' ;
                --end if;

                    if counter = 0 and enable = '1' then
    
                        B_temp := '0' & B ;
                        B_comp := '1' & (unsigned(not(B)) + '1') ; -- concatenate 1 as B_temp is concatenated with 0 in MSB, so complement is 1
                        T      := (others => '0') ;
                        Q      := A ;

                        T      := T(N-1 downto 0) & Q(N-1) ;
                        T      := unsigned(T) + unsigned(B_comp) ;           -- T - B
                        if T(N) = '1' then                     -- this means it's negative --> LSB of Q is 0 && Restore T
                            Q  := Q(N-2 downto 0) & '0' ;
                            T  := unsigned(T) + unsigned(B_temp) ;
                        else                             -- this means it's positive --> LSB of Q is 0 
                            Q  := Q(N-2 downto 0) & '1' ;
                        end if;

				    		busy_bit <= '1' ;
					    	valid_bit <= '0' ;
					    	counter := counter + 1 ;

                    elsif counter = N-1 then -- N = 4
                        T      := T(N-1 downto 0) & Q(N-1) ;
                        T      := unsigned(T) + unsigned(B_comp) ;           -- T - B
                        if T(N) = '1' then                     -- this means it's negative --> LSB of Q is 0 && Restore T
                            Q  := Q(N-2 downto 0) & '0' ;
                            T  := unsigned(T) + unsigned(B_temp) ;
                        else                             -- this means it's positive --> LSB of Q is 0 
                            Q  := Q(N-2 downto 0) & '1' ;
                        end if;

                        M      <= Q ;
                        R      <= T(N-1 downto 0) ;
                        valid_bit <= '1' ;

                        counter := 0 ;
    
					    busy_bit <= '0' ;

                    elsif counter /= 0 then

                        T      := T(N-1 downto 0) & Q(N-1) ;
                        T      := unsigned(T) + unsigned(B_comp) ;           -- T - B
                        if T(N) = '1' then                   -- this means it's negative --> LSB of Q is 0 && Restore T
                            Q  := Q(N-2 downto 0) & '0' ;
                            T  := unsigned(T) + unsigned(B_temp) ;
                        else                             -- this means it's positive --> LSB of Q is 0 
                            Q  := Q(N-2 downto 0) & '1' ;
                        end if;   
    
				    	busy_bit <= '1' ;
				    	valid_bit <= '0' ;
				    	counter := counter + 1 ;
                    else
                        busy_bit  <= '0' ;
				    	valid_bit <= '0' ;
                        error_bit <= '0' ;
                    end if;
			    end if;
                --counter := counter + 1 ;

            else
            ----- multiplication
				if enable = '1' then 
		            acc :=  (others => '0');
		            acc(n-1 downto 0) :=B;

		            if acc(0) = '1' then       --if this bit of b = 1 then add a to acc
		            	acc(2*N downto N) := unsigned(acc(2*N downto N)) + unsigned(('0' & A)); 
		            end if; 
		            acc := '0' & acc(2*N downto 1) ;
		            busy_bit  <='1';
		            valid_bit <='0';
		            cnt:=(others => '0');
	
	            elsif cnt < (N-1) then
	            	busy_bit  <='1';
	            	valid_bit <='0';
	            	if acc(0) = '1' then       --if this bit of b = 1 then add a to acc
	            		acc(2*N downto N) := unsigned(acc(2*N downto N)) + unsigned(('0' & A)); 
	            	end if; 
	            	acc := '0' & acc(2*N downto 1) ;
	            	cnt := cnt + 1 ;
	            	if (cnt=n-1) then
	            		busy_bit  <='0' ;
	            		valid_bit <='1' ;
                        M <= acc(2*N -1 downto N);
                        R <= acc(N-1 downto 0);	
	            	end if;
	            else 
	                busy_bit  <='0' ;
	                valid_bit <='0' ;
	            end if;
			end if;
        end if; 
    end process;

end architecture behav;


architecture comb of mul_div is
    --signal divide_by_zero : std_logic;
begin 
	--divide_by_zero <= '1' when (B = "0000") else '0'; -- Output '1' if vector is zero, '0' otherwise

    process(A, B ,enable) is
        variable counter : integer range 0 to N := 0 ;

        variable B_temp  : std_logic_vector(N downto 0)   := (others => '0') ; 
        variable B_comp  : std_logic_vector(N downto 0)   := (others => '0') ;

        variable T       : std_logic_vector(N downto 0)   := (others => '0') ;
        variable Q       : std_logic_vector(N-1 downto 0) := (others => '0') ;

		--Multiplier
		variable cnt     : unsigned(N-1 downto 0):= (others => '0');
		variable acc     : std_logic_vector(2*N downto 0);

    begin
        if sel = '1' then
            for i in 0 to N-1 loop

                --valid_bit <= '0' ;
		    	if B = "0000" then 
		    		error_bit <= '1' ;
		    		valid_bit <= '0' ;
		    		busy_bit <= '0' ;
		    		M      <= (others => '0') ;
                    R      <= (others => '0') ;
		    		B_temp := (others => '0');
                    B_comp := (others => '0') ; 
                    T      := (others => '0') ;
                    Q      := (others => '0') ;
    
    
		    	else
                    error_bit <= '0' ;

		    	  if enable = '1' then
                    if i = 0 then 
		    			-- busy_bit <= '1' ;
                        B_temp := '0' & B ;
                        B_comp := '1' & (unsigned(not(B)) + '1') ; -- concatenate 1 as B_temp is concatenated with 0 in MSB, so complement is 1
                        T      := (others => '0') ;
                        Q      := A ;

                        T      := T(N-1 downto 0) & Q(N-1) ;
                        T      := unsigned(T) + unsigned(B_comp) ;           -- T - B
                        if T(N) = '1' then                     -- this means it's negative --> LSB of Q is 0 && Restore T
                            Q  := Q(N-2 downto 0) & '0' ;
                            T  := unsigned(T) + unsigned(B_temp) ;
                        else                             -- this means it's positive --> LSB of Q is 0 
                            Q  := Q(N-2 downto 0) & '1' ;
                        end if;
                        
                        M      <= (others => '0') ;
                        R      <= (others => '0') ;
    
		    			busy_bit <= '1' ;
		    			valid_bit <= '0' ;

                    elsif i = N-1 then -- N = 4
                        T      := T(N-1 downto 0) & Q(N-1) ;
                        T      := unsigned(T) + unsigned(B_comp) ;           -- T - B
                        if T(N) = '1' then                     -- this means it's negative --> LSB of Q is 0 && Restore T
                            Q  := Q(N-2 downto 0) & '0' ;
                            T  := unsigned(T) + unsigned(B_temp) ;
                        else                             -- this means it's positive --> LSB of Q is 0 
                            Q  := Q(N-2 downto 0) & '1' ;
                        end if;
                    
                        M      <= Q ;
                        R      <= T(N-1 downto 0) ;

                        valid_bit <= '1' ;
			    		busy_bit  <= '0' ;
    
                    elsif i /= 0 then
                        
                        T      := T(N-1 downto 0) & Q(N-1) ;
                        T      := unsigned(T) + unsigned(B_comp) ;           -- T - B
                        if T(N) = '1' then                   -- this means it's negative --> LSB of Q is 0 && Restore T
                            Q  := Q(N-2 downto 0) & '0' ;
                            T  := unsigned(T) + unsigned(B_temp) ;
                        else                             -- this means it's positive --> LSB of Q is 0 
                            Q  := Q(N-2 downto 0) & '1' ;
                        end if;   
    
			    		busy_bit  <= '1' ;
                        valid_bit <= '0' ;

                        M      <= (others => '0') ;
                        R      <= (others => '0') ;
    
			    	else
			    		B_temp := (others => '0');
                        B_comp := (others => '0') ; 
                        T      := (others => '0') ;
                        Q      := (others => '0') ;
			    		
                        valid_bit <= '0' ;
			    		busy_bit  <= '0' ;

                        M      <= (others => '0') ;
                        R      <= (others => '0') ;
    
                    end if;
			      else
			    	valid_bit <= '0' ;
                    busy_bit  <= '0' ;
                    error_bit <= '0' ;

                    M      <= (others => '0') ;
                    R      <= (others => '0') ;
			      end if;
			    end if;
        end loop ;
        else 
            if enable ='0' then
		
			    busy_bit  <= '0' ;
			    valid_bit <= '0' ;
                error_bit <= '0' ;
			    M         <= (others => '0') ;
		        R         <= (others => '0') ;
		    else 
                error_bit <= '0' ;
			    for i in 0 to N-1 loop 
                    if i = 0 then
                        acc(2*N downto N) := (others => '0') ;
                        acc(N-1 downto 0) := B ;
                    end if ;

			    	if B(i) = '1' then
			    		acc(2*N downto N) := unsigned(acc(2*N downto N)) + unsigned(('0' & A)) ; 
			    		acc := '0' & acc(2*N downto 1) ;
			    	else 
			    		acc := '0' & acc(2*N downto 1) ;
			    	end if;

                    if i = N-1 then 
                        M <= acc(2*N-1 downto N) ;
		                R <= acc(N-1 downto 0)   ;
                    else
                        M <= (others => '0') ;
		                R <= (others => '0') ;
                    end if ;

			        busy_bit  <= '0' ;
			        valid_bit <= '1' ;
                    
			    end loop;

		    end if;
        end if;
    end process;

end architecture comb;