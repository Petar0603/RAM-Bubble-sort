library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is

	generic(
		ADDR_BITS : integer;
		BIT_WIDTH : integer
		);

	port(
		w_data : in std_logic_vector(BIT_WIDTH - 1 downto 0);
		r_addr : in std_logic_vector(ADDR_BITS - 1 downto 0);
		w_addr : in std_logic_vector(ADDR_BITS - 1 downto 0);
		we : in std_logic;
		rst : in std_logic;
		clk : in std_logic;
		r_data : out std_logic_vector(BIT_WIDTH - 1 downto 0)
	);

end ram;

architecture arch of ram is

	type reg_array is array ((2**ADDR_BITS - 1) downto 0) of std_logic_vector(BIT_WIDTH - 1 downto 0);
	signal memory : reg_array := (others => (others => '0'));

begin

	process(clk, rst)
	begin
		if rst = '1' then
			memory <= (others => (others => '0'));
		elsif(clk'event and clk = '1') then
			if we = '1' then
				memory(to_integer(unsigned(w_addr))) <= w_data;
			end if;
		end if;
	end process;

	r_data <= memory(to_integer(unsigned(r_addr)));

end arch;