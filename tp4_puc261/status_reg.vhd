LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY status_reg IS
    PORT (
        nrst               : IN  STD_LOGIC;
        clk_in             : IN  STD_LOGIC;
        status_reg_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        status_reg_wr_ena  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        status_reg_out     : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF status_reg IS
    SIGNAL regs : STD_LOGIC_VECTOR(4 DOWNTO 0);
BEGIN


    PROCESS(nrst, clk_in)
    BEGIN
        IF nrst = '0' THEN
            regs <= (OTHERS => '0');
        ELSIF RISING_EDGE(clk_in) THEN
            FOR i IN 0 TO 4 LOOP
                IF status_reg_wr_ena(i) = '1' THEN
                    regs(i) <= status_reg_in(i);
                END IF;
            END LOOP;
        END IF;
    END PROCESS;


    status_reg_out <= regs;
END rtl;
