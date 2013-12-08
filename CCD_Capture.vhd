
-- Camera Tracking

-- Goal:


-- Change Log:

-- Import the definitions for standard logic
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity CCD_Capture is port(
					oDATA: out STD_lOGIC_VECTOR(11 downto 0);
					oDVAL: out STD_LOGIC;
					oX_Cont: out STD_LOGIC_VECTOR(15 downto 0);
					oY_Cont: out STD_LOGIC_VECTOR(15 downto 0);
					oFrame_Cont: out STD_LOGIC_VECTOR(31 downto 0);
					iDATA: in STD_LOGIC_VECTOR(11 downto 0);
					iFVAL: in STD_LOGIC;
					iLVAL: in STD_LOGIC;
					iSTART: in STD_LOGIC;
					iEND: in STD_LOGIC;
					iCLK: in STD_LOGIC;
					iRST: in STD_LOGIC					
					);
end ;
	

architecture behavior of CCD_Capture is 

type states is (NotFrame, PreLine,IsLine);

-- declare encoding of states;
	attribute syn_encoding : string;
	attribute syn_encoding of states : type is "00 01 10";
	
-- two regesters of type states;
signal CurrentState,NextState: states;

signal ValidData: STD_LOGIC;
signal mFrameCnt: integer ; --range 0 to 56000 :0;
signal xcnt: integer := 0;
signal ycnt: integer := 0;
signal reset: STD_LOGIC;

signal Data: STD_LOGIC_VECTOR(11 downto 0);
signal FVAL: STD_LOGIC;
signal LVAL: STD_LOGIC;

signal outofcontrol: STD_LOGIC;
begin
	reset <= iRST;
	process(iCLK)
	begin
		--if((reset = '1')) then
		--	currentState <= NotFrame;
		--els
		if(falling_edge(iCLK))then
			 
			-- copy the next state to the current state
			Data <= iDATA;
			FVAL <= iFVAL;
			LVAL <= iLVAL;
			
			currentState <= nextState;
		end if;
	end process;
	
	
	process(iCLK)begin -- this is the frame valid signal
		if(falling_edge(iCLK))then
			if(iRST = '0')then
				xcnt <= 0;
				ycnt <= 0;
			elsif(ValidData = '1')then
				
				oDATA <= DATA;
				if(xcnt > 0)then
					xcnt <= xcnt -1;
				else	
					xcnt <= 2591;
					
					if(ycnt > 0) then 
						ycnt <= ycnt -1;
					else 
						ycnt <= 1943;
					end if;
				end if;
				
			elsif(FVAL = '0' and LVAL = '0') then -- still valid just waiting for the next line
				--xcnt <= 0;
				--ycnt <= 0;
			end if;
		
		end if; 
	end process;
	
	
	ValidData <= FVAL AND LVAL;  -- is the data valid?
	oDVAL <= outofcontrol;--ValidData;
	
	oFrame_Cont <= std_logic_vector(to_unsigned(mFrameCnt, 32));
	oX_Cont <= std_logic_vector(to_unsigned(xcnt, 16));
	oY_Cont <= std_logic_vector(to_unsigned(ycnt, 16));
	process(FVAL)begin -- this is the frame valid signal
		if(falling_edge(FVAL))then
			mFrameCnt <= mFrameCnt + 1;
		end if; 
		
	end process;
	
	
end behavior;
