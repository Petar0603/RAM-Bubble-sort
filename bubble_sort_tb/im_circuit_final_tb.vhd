library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity im_final_circuit_tb is
end im_final_circuit_tb;

architecture im_final_circuit_tb of im_final_circuit_tb is

	component im_final_circuit is
		generic(
			ADDR_BITS : integer;
			BIT_WIDTH : integer
			);
		port(
			clk : in std_logic;
			rst : in std_logic;
			start : in std_logic;
			rdy : out std_logic;
			we : in std_logic;
			r_data : out std_logic_vector(BIT_WIDTH - 1 downto 0);
			r_addr : in std_logic_vector(ADDR_BITS - 1 downto 0);
			w_addr : in std_logic_vector(ADDR_BITS - 1 downto 0);
			w_data : in std_logic_vector(BIT_WIDTH - 1 downto 0)
			);
	end component;

	signal clk,rst,start,rdy,we : std_logic;
	signal r_data : std_logic_vector(7 downto 0);
	signal r_addr : std_logic_vector(5 downto 0);
	signal w_addr: std_logic_vector(5 downto 0);
	signal w_data : std_logic_vector(7 downto 0);

	constant clk_period : time := 10ns;
	constant ADDR_BITS : integer := 6;
	constant BIT_WIDTH : integer := 8;

begin

	im_final_circuit_unit: im_final_circuit
		generic map(
			ADDR_BITS => ADDR_BITS,
			BIT_WIDTH => BIT_WIDTH
			)
		port map(
			r_addr => r_addr,
			r_data => r_data,
			w_addr => w_addr,
			w_data => w_data,
			we => we,
			rst => rst,
			clk => clk,
			start => start,
			rdy => rdy
			);

		process begin
			clk <= '0';
			wait for clk_period / 2;
			clk <= '1';
			wait for clk_period / 2;
		end process;

		process

			procedure write_ram is
				type int_array is array(0 to 15) of integer;
				variable A : int_array := (22,71,19,2,115,48,201,22,50,111,72,9,98,82,228,189);
				begin
					we <= '1';
					for i in 0 to 15 loop
						w_addr <= std_logic_vector(to_unsigned(i,6));
						w_data <= std_logic_vector(to_unsigned(A(i),8));
						wait for clk_period;
					end loop;
					we <= '0';
				end ;

		begin

			start <= '0';
			rst <= '1';
			wait for clk_period * 10; -- 100 ns

			rst <= '0';
			write_ram; -- 160 ns
			start <= '1';
			wait for clk_period; -- 10 ns
			start <= '0';
			wait for 3090ns; -- 3090 ns
			
			for j in 0 to 15 loop -- 160 ns
			     r_addr <= std_logic_vector(to_unsigned(j,6));
			     wait for clk_period;
			end loop;
			wait;
            -- 3520 ns total
		end process;
end im_final_circuit_tb;