library ieee;
use ieee.std_logic_1164.all;

entity im_block is

	generic(

		ADDR_BITS : integer;
		BIT_WIDTH : integer

		);

	port(

		start : in std_logic;
		clk : in std_logic;
		rst : in std_logic;
		rdy : out std_logic;

		r_addr : out std_logic_vector(ADDR_BITS - 1 downto 0);
		w_addr : out std_logic_vector(ADDR_BITS - 1 downto 0);
		w_data : out std_logic_vector(BIT_WIDTH - 1 downto 0);
		we : out std_logic;

		p : in std_logic_vector(ADDR_BITS - 1 downto 0);
		r_data : in std_logic_vector(BIT_WIDTH - 1 downto 0)

		);

end im_block;

architecture arch of im_block is

	component datapath is
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
	end component;

	component control_unit is
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
	end component;

	signal clri : std_logic;
	signal eni : std_logic;
	signal enj : std_logic;
	signal ldj : std_logic;
	signal ldpom : std_logic;
	signal comp1 : std_logic;
	signal comp2 : std_logic;
	signal sel_comp : std_logic;
	signal sel_r_addr : std_logic;
	signal sel_w_addr : std_logic;
	signal sel_w_data : std_logic;

begin
	datapath_component: datapath
		generic map(
			ADDR_BITS => ADDR_BITS,
			BIT_WIDTH => BIT_WIDTH
			)
		port map(
			clk => clk,
			rst => rst,
			clri => clri,
			eni => eni,
			enj => enj,
			ldj => ldj,
			p => p,
			r_data => r_data,
			ldpom => ldpom,
			comp1 => comp1,
			comp2 => comp2,
			sel_comp => sel_comp,
			r_addr => r_addr,
			w_addr => w_addr,
			w_data => w_data,
			sel_r_addr => sel_r_addr,
			sel_w_addr => sel_w_addr,
			sel_w_data => sel_w_data
			);
	control_unit_component: control_unit
		port map(
			clk => clk,
			rst => rst,
			clri => clri,
			eni => eni,
			enj => enj,
			ldj => ldj,
			ldpom => ldpom,
			comp1 => comp1,
			comp2 => comp2,
			sel_comp => sel_comp,
			sel_r_addr => sel_r_addr,
			sel_w_addr => sel_w_addr,
			sel_w_data => sel_w_data,
			start => start,
			rdy => rdy,
			we => we
			);
end arch;