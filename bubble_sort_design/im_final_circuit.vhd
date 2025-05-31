-- this is a VHDL code for intelligent memory which performs bubble sort of ram content when 'start' is high
-- final circuit contains:
-- ram
-- im_block (datapath and control unit which perform bubble sort)
-- counter of memory locations occupied (necessary for the sorting algorithm)
-- multiplexers which control if user sets the signals for ram or im_block does that when sorting (based on rdy signal)

library ieee;
use ieee.std_logic_1164.all;

entity im_final_circuit is

	generic(

		ADDR_BITS : integer := 6;
		BIT_WIDTH : integer := 8

		);

	port(

		clk : in std_logic;
		start : in std_logic;
		rst : in std_logic;

		rdy : out std_logic;

		w_data : in std_logic_vector(BIT_WIDTH - 1 downto 0);
		r_addr : in std_logic_vector(ADDR_BITS - 1 downto 0);
		w_addr : in std_logic_vector(ADDR_BITS - 1 downto 0);
		we : in std_logic;

		r_data : out std_logic_vector(BIT_WIDTH - 1 downto 0)

		);

end im_final_circuit;

architecture arch of im_final_circuit is

	component im_block is
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
	end component;

	component ram is
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
	end component;

	signal clk : std_logic;
	signal start : std_logic;
	signal rst : std_logic;
	signal rdy : std_logic;
	signal w_data : std_logic_vector(BIT_WIDTH - 1 downto 0);
	signal r_addr : std_logic_vector(ADDR_BITS - 1 downto 0);
	signal w_addr : std_logic_vector(ADDR_BITS - 1 downto 0);
	signal we : std_logic;
	signal r_data : std_logic_vector(BIT_WIDTH - 1 downto 0);

	-- im_block interconnections with other components
	signal rdy_i : std_logic;
	signal r_addr_i : std_logic_vector(ADDR_BITS - 1 downto 0);
	signal w_addr_i : std_logic_vector(ADDR_BITS - 1 downto 0);
	signal w_data_i : std_logic_vector(BIT_WIDTH - 1 downto 0);
	signal we_i : std_logic;
	signal p_i : std_logic_vector(ADDR_BITS - 1 downto 0);
	signal r_data_i : std_logic_vector(BIT_WIDTH - 1 downto 0);

	-- multiplexer outputs
	signal r_addr_mux : std_logic_vector(ADDR_BITS - 1 downto 0);
	signal w_addr_mux : std_logic_vector(ADDR_BITS - 1 downto 0);
	signal w_data_mux : std_logic_vector(BIT_WIDTH - 1 downto 0);
	signal we_mux : std_logic;

begin

	im_block_unit: im_block
		generic map(
			ADDR_BITS => ADDR_BITS,
			BIT_WIDTH => BIT_WIDTH
			)
		port map(
			start => start,
			clk => clk,
			rst => rst,
			rdy => rdy_i,
			r_addr => r_addr_i,
			w_addr => w_addr_i,
			w_data => w_data_i,
			we => we_i,
			p => p_i,
			r_data => r_data_i
			);

	ram_unit: ram
		generic map(
			ADDR_BITS => ADDR_BITS,
			BIT_WIDTH => BIT_WIDTH
			)
		port map(
			w_data => w_data_mux,
			r_addr => r_addr_mux,
			w_addr => w_addr_mux,
			we => we_mux,
			rst => rst,
			clk => clk,
			r_data => r_data_i
			);

	r_data <= r_data_i;
	rdy <= rdy_i;

	-- p counter of current memory locations occupied in ram
	process(clk,rst) begin
		if(rst = '1') then
			p_i <= (others => '0');
		elsif(clk'event and clk = '1' and we = '1') then -- when we is high we have written data to a memory location, so p counter is incremented!
			p_i <= std_logic_vector(unsigned(p_i) + 1);
		end if;
	end process;

	-- multiplexers
	-- when rdy is '0' im_block is sorting the ram
	-- when rdy is '1' user can write to ram
	with rdy_i select
		r_addr_mux <= r_addr_i when '0',
					  r_addr when others;

	with rdy_i select
		w_addr_mux <= w_addr_i when '0',
					  w_addr when others;

	with rdy_i select
		w_data_mux <= w_data_i when '0',
					  w_data when others;

	with rdy_i select
		we_mux <= we_i when '0',
				  we when others;

end arch;