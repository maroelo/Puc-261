library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    port (
        a_in      : in  std_logic_vector(7 downto 0); 
        b_in      : in  std_logic_vector(7 downto 0); 
        c_in      : in  std_logic;                    
        op_sel    : in  std_logic_vector(3 downto 0); 
        r_out     : out std_logic_vector(7 downto 0); 
        flags_out : out std_logic_vector(4 downto 0) 
    );
end entity ALU;

architecture combinacional of ALU is


    signal c_in_vec : unsigned(8 downto 0);
    signal add_res, adc_res, sub_res, sbc_res : std_logic_vector(8 downto 0);
    

    signal c_in_vec_h : unsigned(4 downto 0);
    signal add_h, adc_h, sub_h, sbc_h : std_logic_vector(4 downto 0);


    signal result : std_logic_vector(7 downto 0);
    

    signal c_flag, h_flag, v_flag, z_flag, n_flag : std_logic;

begin


    c_in_vec   <= "00000000" & c_in;
    c_in_vec_h <= "0000" & c_in;


 
    add_res <= std_logic_vector(unsigned('0' & a_in) + unsigned('0' & b_in));
    adc_res <= std_logic_vector(unsigned('0' & a_in) + unsigned('0' & b_in) + c_in_vec);
    sub_res <= std_logic_vector(unsigned('0' & a_in) - unsigned('0' & b_in));
    sbc_res <= std_logic_vector(unsigned('0' & a_in) - unsigned('0' & b_in) - c_in_vec);


    add_h <= std_logic_vector(unsigned('0' & a_in(3 downto 0)) + unsigned('0' & b_in(3 downto 0)));
    adc_h <= std_logic_vector(unsigned('0' & a_in(3 downto 0)) + unsigned('0' & b_in(3 downto 0)) + c_in_vec_h);
    sub_h <= std_logic_vector(unsigned('0' & a_in(3 downto 0)) - unsigned('0' & b_in(3 downto 0)));
    sbc_h <= std_logic_vector(unsigned('0' & a_in(3 downto 0)) - unsigned('0' & b_in(3 downto 0)) - c_in_vec_h);


    WITH op_sel SELECT
        result <=
            add_res(7 downto 0)            WHEN "0000", -- ADD
            adc_res(7 downto 0)            WHEN "0001", -- ADDC
            sub_res(7 downto 0)            WHEN "0010", -- SUB
            sbc_res(7 downto 0)            WHEN "0011", -- SUBC
            a_in AND b_in                  WHEN "0100", -- AND
            a_in OR b_in                   WHEN "0101", -- OR
            a_in XOR b_in                  WHEN "0110", -- XOR
            b_in                           WHEN "0111", -- PASS B
            a_in(6 downto 0) & c_in        WHEN "1000", -- RLC
            c_in & a_in(7 downto 1)        WHEN "1001", -- RRC
            a_in(6 downto 0) & a_in(7)     WHEN "1010", -- RL
            a_in(0) & a_in(7 downto 1)     WHEN "1011", -- RR
            a_in(6 downto 0) & '0'         WHEN "1100", -- SLL
            '0' & a_in(7 downto 1)         WHEN "1101", -- SRL
            a_in(7) & a_in(7 downto 1)     WHEN "1110", -- SRA
            NOT a_in                       WHEN "1111", -- NOT
            "00000000"                     WHEN OTHERS;


    WITH op_sel SELECT
        c_flag <=
            add_res(8)  WHEN "0000", 
            adc_res(8)  WHEN "0001",
            sub_res(8)  WHEN "0010", 
            sbc_res(8)  WHEN "0011",
            a_in(7)     WHEN "1000", 
            a_in(0)     WHEN "1001", 
            a_in(7)     WHEN "1010", 
            a_in(0)     WHEN "1011", 
            a_in(7)     WHEN "1100", 
            a_in(0)     WHEN "1101", 
            a_in(0)     WHEN "1110", 
            '0'         WHEN OTHERS;


    WITH op_sel SELECT
        h_flag <=
            add_h(4) WHEN "0000",
            adc_h(4) WHEN "0001",
            sub_h(4) WHEN "0010",
            sbc_h(4) WHEN "0011",
            '0'      WHEN OTHERS;


    WITH op_sel SELECT
        v_flag <=

            (a_in(7) AND b_in(7) AND NOT add_res(7)) OR (NOT a_in(7) AND NOT b_in(7) AND add_res(7)) WHEN "0000",
            (a_in(7) AND b_in(7) AND NOT adc_res(7)) OR (NOT a_in(7) AND NOT b_in(7) AND adc_res(7)) WHEN "0001",

            (a_in(7) AND NOT b_in(7) AND NOT sub_res(7)) OR (NOT a_in(7) AND b_in(7) AND sub_res(7)) WHEN "0010",
            (a_in(7) AND NOT b_in(7) AND NOT sbc_res(7)) OR (NOT a_in(7) AND b_in(7) AND sbc_res(7)) WHEN "0011",
            '0' WHEN OTHERS;


    z_flag <= '1' WHEN result = "00000000" ELSE '0';
    n_flag <= result(7);


    r_out <= result;
    

    flags_out <= n_flag & v_flag & z_flag & h_flag & c_flag;

end architecture combinacional;