LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY reg_bank IS
    PORT (
        clk_in : IN  STD_LOGIC;
        nrst   : IN  STD_LOGIC;
        di     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        a_sel  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        b_sel  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        wr_ena : IN  STD_LOGIC;
        a_do   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        b_do   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF reg_bank IS
    TYPE reg_array_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL regs : reg_array_t;
BEGIN


    PROCESS(nrst, clk_in)
    BEGIN
        IF nrst = '0' THEN
            regs <= (OTHERS => (OTHERS => '0'));
        ELSIF RISING_EDGE(clk_in) THEN
            IF wr_ena = '1' THEN
                regs(TO_INTEGER(UNSIGNED(a_sel))) <= di;
            END IF;
        END IF;
    END PROCESS;


    a_do <= regs(TO_INTEGER(UNSIGNED(a_sel)));
    b_do <= regs(TO_INTEGER(UNSIGNED(b_sel)));
END rtl;
