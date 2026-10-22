LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;






ENTITY ram_256x8 IS
    PORT (
        nrst   : IN    STD_LOGIC;
        clk_in : IN    STD_LOGIC;
        abus   : IN    STD_LOGIC_VECTOR(8 DOWNTO 0);
        dio    : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        r_nwr  : IN    STD_LOGIC;
        nce    : IN    STD_LOGIC
    );
END ENTITY;

ARCHITECTURE arch OF ram_256x8 IS
    TYPE mem_type IS ARRAY(0 TO 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL mem_reg  : mem_type;
    SIGNAL addr_int : INTEGER RANGE 0 TO 255;
    SIGNAL wr_en    : STD_LOGIC;
    SIGNAL rd_en    : STD_LOGIC;


    ATTRIBUTE ramstyle : STRING;
    ATTRIBUTE ramstyle OF mem_reg : SIGNAL IS "M4K";
BEGIN




    addr_int <= TO_INTEGER(UNSIGNED(abus(7 DOWNTO 0)));




    rd_en <= '1' WHEN (nce = '0' AND r_nwr = '1' AND abus(8) = '0') ELSE '0';
    wr_en <= '1' WHEN (nce = '0' AND r_nwr = '0' AND abus(8) = '0') ELSE '0';


    PROCESS(clk_in)
    BEGIN
        IF RISING_EDGE(clk_in) THEN
            IF wr_en = '1' THEN
                mem_reg(addr_int) <= dio;
            END IF;
        END IF;
    END PROCESS;


    dio <= mem_reg(addr_int) WHEN rd_en = '1' ELSE (OTHERS => 'Z');
END arch;
