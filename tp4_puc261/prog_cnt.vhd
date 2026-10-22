LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY prog_cnt IS
    PORT (
        nrst        : IN  STD_LOGIC;
        clk_in      : IN  STD_LOGIC;
        pc_ctrl     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        new_pc_in   : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        from_stack  : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        next_pc_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        pc_out      : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF prog_cnt IS
    SIGNAL pc_reg  : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL next_pc : STD_LOGIC_VECTOR(9 DOWNTO 0);
BEGIN

    PROCESS(pc_reg, pc_ctrl, new_pc_in, from_stack)
    BEGIN
        CASE pc_ctrl IS
            WHEN "00" =>
                next_pc <= pc_reg;
            WHEN "01" =>
                next_pc <= STD_LOGIC_VECTOR(UNSIGNED(pc_reg) + 1);
            WHEN "10" =>
                next_pc <= new_pc_in;
            WHEN "11" =>
                next_pc <= from_stack;
            WHEN OTHERS =>
                next_pc <= pc_reg;
        END CASE;
    END PROCESS;


    PROCESS(nrst, clk_in)
    BEGIN
        IF nrst = '0' THEN
            pc_reg <= (OTHERS => '0');
        ELSIF RISING_EDGE(clk_in) THEN
            pc_reg <= next_pc;
        END IF;
    END PROCESS;

    next_pc_out <= next_pc;
    pc_out      <= pc_reg;
END rtl;
