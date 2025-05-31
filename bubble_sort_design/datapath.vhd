library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is

	generic(

		ADDR_BITS : integer;
		BIT_WIDTH : integer

		);

	port(

		clk : in std_logic;
		rst : in std_logic;

		clri : in std_logic;
		eni : in std_logic;

		enj : in std_logic;
		ldj : in std_logic;

		p : in std_logic_vector(ADDR_BITS - 1 downto 0);
		r_data : in std_logic_vector(BIT_WIDTH - 1 downto 0);

		ldpom : in std_logic;

		comp1 : out std_logic;
		comp2 : out std_logic;

		sel_comp : in std_logic;

		r_addr : out std_logic_vector(ADDR_BITS - 1 downto 0);
		w_addr : out std_logic_vector(ADDR_BITS - 1 downto 0);
		w_data : out std_logic_vector(BIT_WIDTH - 1 downto 0);

		sel_r_addr : in std_logic;
		sel_w_addr : in std_logic;
		sel_w_data : in std_logic

		);
end datapath;

architecture arch of datapath is

	signal reg_i, reg_j, mux : unsigned(ADDR_BITS - 1 downto 0);
	signal reg_pom : std_logic_vector(BIT_WIDTH - 1 downto 0);

begin

	-- register 'i' - counter with synchronous reset 'clri', asynchronous reset 'rst' and enable 'eni'
	process(clk, rst) begin
		if(rst) then

			reg_i <= (others => '0');

		elsif(clk'event and clk = '1') then
			if(clri = '1') then

				reg_i <= (others => '0');

			elsif(eni = '1') then

				reg_i <= reg_i + 1;

			end if;
		end if;
	end process;

	-- register 'j' - counter with asynchronous reset 'rst', enable 'enj' and latch data 'ldj'
	process(clk, rst) begin
		if(rst) then

			reg_j <= (others => '0');

		elsif(clk'event and clk = '1') then
			if(ldj = '1') then

				reg_j <= unsigned(p) - 1;

			elsif(enj = '1') then

				reg_j <= reg_j - 1;

			end if;
		end if;
	end process;

	-- register 'pom' - counter with asynchronous reset 'rst' and latch data 'ldpom'
	process(clk, rst) begin
		if(rst) then

			reg_pom <= (others => '0');

		elsif(clk'event and clk = '1') then
			if(ldpom = '1') then

				reg_pom <= r_data;

			end if;
		end if;
	end process;

	-- first 'less than' comparator
	comp1 <= '1' when reg_i < mux else '0';

	-- multiplexer on the second input of the first 'less than' comaparator
	with sel_comp select
		mux <= unsigned(p) - 1 when '0',
				reg_j when others;

	-- second 'less than' comparator
	comp2 <= '1' when reg_pom < unsigned(r_data) else '0';

	-- read address multiplexer
	with sel_r_addr select
		r_addr <= std_logic_vector(reg_j) when '0',
				  std_logic_vector(reg_j - 1) when others;

	-- write address multiplexer
	with sel_w_addr select
		w_addr <= std_logic_vector(reg_j) when '0',
				  std_logic_vector(reg_j - 1) when others;

	-- write data multiplexer
	with sel_w_data select
		w_data <= r_data when '0',
				  reg_pom when others;

end arch;