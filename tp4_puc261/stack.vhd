LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY stack IS
    PORT (
        nrst       : IN  STD_LOGIC;
        clk_in     : IN  STD_LOGIC;
        stack_in   : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        stack_push : IN  STD_LOGIC;
        stack_pop  : IN  STD_LOGIC;
        stack_out  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF stack IS
    TYPE stack_array_t IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL stack_reg : stack_array_t;
BEGIN
    PROCESS(nrst, clk_in)
    BEGIN
        IF nrst = '0' THEN
            stack_reg <= (OTHERS => (OTHERS => '0'));
        ELSIF RISING_EDGE(clk_in) THEN

            IF stack_push = '1' THEN
                FOR i IN 7 DOWNTO 1 LOOP
                    stack_reg(i) <= stack_reg(i-1);
                END LOOP;
                stack_reg(0) <= stack_in;
            ELSIF stack_pop = '1' THEN
                FOR i IN 0 TO 6 LOOP
                    stack_reg(i) <= stack_reg(i+1);
                END LOOP;
                stack_reg(7) <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;


    stack_out <= stack_reg(0);
END rtl;
