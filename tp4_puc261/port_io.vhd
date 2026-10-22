LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;





ENTITY port_io IS
    GENERIC (
        base_addr : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"
    );
    PORT (
        nrst    : IN    STD_LOGIC;
        clk_in  : IN    STD_LOGIC;
        abus    : IN    STD_LOGIC_VECTOR(8 DOWNTO 0);
        dbus    : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        r_nwr   : IN    STD_LOGIC;
        nce     : IN    STD_LOGIC;
        port_io : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch OF port_io IS
    SIGNAL port_reg         : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL dir_reg          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL port_latch       : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL base_addr_plus_1 : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL sel_port : STD_LOGIC;
    SIGNAL sel_dir  : STD_LOGIC;
    SIGNAL wr_port  : STD_LOGIC;
    SIGNAL wr_dir   : STD_LOGIC;
    SIGNAL rd_port  : STD_LOGIC;
    SIGNAL rd_dir   : STD_LOGIC;
BEGIN

    base_addr_plus_1 <= STD_LOGIC_VECTOR(UNSIGNED(base_addr) + TO_UNSIGNED(1, 8));


    sel_port <= '1' WHEN (abus(8) = '1' AND abus(7 DOWNTO 0) = base_addr) ELSE '0';
    sel_dir  <= '1' WHEN (abus(8) = '1' AND abus(7 DOWNTO 0) = base_addr_plus_1) ELSE '0';




    wr_port <= '1' WHEN (nce = '0' AND sel_port = '1' AND r_nwr = '0') ELSE '0';
    wr_dir  <= '1' WHEN (nce = '0' AND sel_dir  = '1' AND r_nwr = '0') ELSE '0';
    rd_port <= '1' WHEN (nce = '0' AND sel_port = '1' AND r_nwr = '1') ELSE '0';
    rd_dir  <= '1' WHEN (nce = '0' AND sel_dir  = '1' AND r_nwr = '1') ELSE '0';


    PROCESS(nrst, clk_in)
    BEGIN
        IF nrst = '0' THEN
            port_reg <= (OTHERS => '0');
            dir_reg  <= (OTHERS => '0');
        ELSIF RISING_EDGE(clk_in) THEN
            IF wr_port = '1' THEN
                port_reg <= dbus;
            END IF;

            IF wr_dir = '1' THEN
                dir_reg <= dbus;
            END IF;
        END IF;
    END PROCESS;




    PROCESS(nrst, rd_port, port_io)
    BEGIN
        IF nrst = '0' THEN
            port_latch <= (OTHERS => '0');
        ELSIF rd_port = '0' THEN
            port_latch <= port_io;
        END IF;
    END PROCESS;



    dbus <= port_latch WHEN rd_port = '1' ELSE
            dir_reg    WHEN rd_dir  = '1' ELSE
            (OTHERS => 'Z');


    gen_port_bits : FOR i IN 0 TO 7 GENERATE
        port_io(i) <= port_reg(i) WHEN dir_reg(i) = '1' ELSE 'Z';
    END GENERATE gen_port_bits;
END arch;
