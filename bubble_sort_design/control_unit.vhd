library ieee;
use ieee.std_logic_1164.all;

entity control_unit is

	port(

		clk : in std_logic;
		rst : in std_logic;
		start : in std_logic;

		rdy : out std_logic;

		clri : out std_logic;
		eni : out std_logic;

		enj : out std_logic;
		ldj : out std_logic;

		ldpom : out std_logic;

		comp1 : in std_logic;
		comp2 : in std_logic;

		sel_comp : out std_logic;
		sel_r_addr : out std_logic;
		sel_w_addr : out std_logic;
		sel_w_data : out std_logic;
		we : out std_logic

		);

end control_unit;

architecture arch of control_unit is

	type state is (idle,s0,s1,s2,s3);
	signal current_state : state := idle;
	signal next_state : state;

begin
	process(clk,rst) begin
		if(rst = '1') then
			current_state <= idle;
		elsif(clk'event and clk = '1') then
			current_state <0 next_state;
		end if;
	end process;

	process(start, current_state, comp1, comp2) begin

		next_state <= current_state;

		-- default values for outputs (control signals for datapath)
		rdy <= '0';
		clri <= '0';
		eni <= '0';
		enj <= '0';
		ldj <= '0';
		ldpom <= '0';
		sel_comp <= '0';
		sel_r_addr <= '0';
		sel_w_addr <= '0';
		sel_w_data <= '0';
		we <= '0';

		case current_state is

			when idle =>
				rdy = '1';
				if(start = '1') then -- if 'start' is high perform sorting
					clri <= '1'; -- 'i' starts from zero
					next_state <= s0;
				end if;

			when s0 =>
				if(comp1 = '1') then -- compare 'i' < 'p-1' (counter of elements present in ram)
					ldj <= '1'; -- register 'j' gets the value of 'p-1' (address of the last element in ram) (later it is decremented)
					next_state <= s1; -- go to compare 'j' > 'i'
				else
					next_state <= idle; -- if 'i' > 'p-1', sorting is done or there are no elements in ram, return to idle
				end if;

			when s1 =>
				sel_comp <= '1'; -- forward register 'j' to comparator to compare 'j' > 'i'
				if(comp1 = '1') then -- if 'j' > 'i' continue sorting
					ldpom <= '1'; -- store data from 'j' location in ram in register 'pom'
					next_state <= s2; -- go to state s2 to compare 'pom' with 'j-1' location in ram
				else
					eni <= '1'; -- increment register 'i'
					next_state <= s0; -- go to state s0 to compare 'i' < 'p-1' again
				end if;

			when s2 =>
				sel_r_addr <= '1'; -- read from 'j-1' address of ram
				if(comp2 = '1') then -- if 'pom' < 'j-1' in ram
					we <= '1'; -- enable writing to ram
					next_state <= s3; -- go to s3 to write 'pom' ('j' in ram) to 'j-1' location
				else
					enj <= '1'; -- decrement 'j'
					next_state <= s1; -- go to compare 'j' > 'i' again
				end if;

			when s3 => -- write ram state
				sel_w_addr <= '1'; -- 'j-1' location
				sel_w_data  <= '1'; -- 'pom' ('j' in ram) value
				we <= '1'; -- enable write
				enj <= '1'; -- decrement 'j'
				next_state <= s1; -- go to compare 'j' > 'i' again

			when others => null;

		end case;
	end process;
end arch;