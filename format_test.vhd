use std.textio.all ;

library ieee ;
    use ieee.std_logic_1164.all ;

library work ;
    use work.format.all ;

entity format_test is
  generic (
    FNAME   :   string := "./vectors/format_test_vectors.txt"
  ) ;
end entity ;

architecture arch of format_test is

    procedure split(variable lines : inout string_list ; variable l : inout line) is
        variable start : positive := 1 ;
        variable stop : positive := 1 ;
        type fsm_t is (WHITESPACE, INQUOTE, INWORD) ;
        variable fsm : fsm_t := WHITESPACE ;
        variable len : natural ;
    begin
        length(lines, len) ;
        clear(lines) ;
        while stop <= l'length loop
            case fsm is
                when WHITESPACE =>
                    case l(stop) is
                        when ' '|HT =>
                            start := start + 1 ;
                            stop := start ;
                        when '"' =>
                            start := start + 1 ;
                            stop := start ;
                            fsm := INQUOTE ;
                        when others =>
                            stop := start ;
                            fsm := INWORD ;
                    end case ;

                when INQUOTE =>
                    case l(stop) is
                        when '"' =>
                            append(lines, l(start to stop-1)) ;
                            start := stop + 1 ;
                            stop := start ;
                            fsm := WHITESPACE ;
                        when others =>
                            stop := stop + 1 ;
                    end case ;

                when INWORD =>
                    case l(stop) is
                        when ' '|HT =>
                            append(lines, l(start to stop-1)) ;
                            start := stop ;
                            fsm := WHITESPACE ;
                        when others =>
                            stop := stop + 1 ;
                    end case ;
            end case ;
        end loop ;
    end procedure ;

    constant ENDL : string := ( CR & LF ) ;

begin

    test : process
        type lines_t is array(positive range <>) of line ;
        file fin            :   text ;
        variable fstatus    :   file_open_status ;
        variable l          :   line ;
        variable bit_arg    :   bit ;
        variable bool_arg   :   boolean ;
        variable char_arg   :   character ;
        variable int_arg    :   integer ;
        variable real_arg   :   real ;
        variable time_arg   :   time ;
        variable lines      :   string_list ;
        variable len        :   natural ;
        variable num_args   :   integer ;
        variable lineno     :   natural := 0 ;
        variable good       :   boolean ;

        variable tests      :   natural := 0 ;
        variable failed     :   natural := 0 ;

        variable cmd        :   line ;
        variable fmt        :   line ;
        variable result     :   line ;
        variable gold       :   line ;
        variable args       :   lines_t(1 to 16) := (others => null) ;
        variable args_list  :   string_list ;
    begin
        -- Open the test file
        file_open(fin, FNAME, READ_MODE) ;

        -- Read the line and parse
        while not endfile(fin) loop
            -- Read the line and keep track of where we are in the file
            readline(fin, l) ;
            lineno := lineno + 1 ;

            -- Check if the current line is commented using a #
            if l(1) = '#' then
                -- Skip
                next ;
            end if ;

            -- Split out whitespace and quoted strings
            split(lines, l) ;

            -- Let the total number of lines we split
            length(lines, len) ;

            -- Calculate arguments given the number of lines we split
            num_args := len - 1 - 1 - 1 ;
            if num_args < 0 then
                report "Invalid test at line " & integer'image(lineno) & ": " & l.all
                    severity warning ;
                next ;
            end if ;

            -- Populate Command
            get(lines, 0, cmd) ;

            -- Populate Format String
            get(lines, 1, fmt) ;

            -- Clear any old arguments
            args := (others => null) ;

            -- Populate the arguments
            if num_args > args'length then
                report fpr("Too many arguments at line {}, trimming to {}", f(lineno,"d"), f(args'length,"d")) ;
                num_args := args'length ;
            end if ;
            for idx in 2 to 1+num_args loop
                get(lines, idx, args(idx-1)) ;
            end loop ;

            -- Last line is always gold
            get(lines, len-1, gold) ;

            -- Process the different commands
            -------------------------------------------------------------------
            -- fbit
            -------------------------------------------------------------------

            -------------------------------------------------------------------
            -- fbool
            -------------------------------------------------------------------

            -------------------------------------------------------------------
            -- fbv
            -------------------------------------------------------------------

            -------------------------------------------------------------------
            -- fchar
            -------------------------------------------------------------------

            -------------------------------------------------------------------
            -- fint
            -------------------------------------------------------------------
            if cmd.all = "fint" then
                read(args(1), int_arg, good) ;
                if good = false then
                    report "Invalid integer read: " & args(1).all
                        severity warning ;
                end if ;
                result := new string'(fint(int_arg, fmt.all)) ;

            -------------------------------------------------------------------
            -- fpr
            -------------------------------------------------------------------
            elsif cmd.all = "fpr" then
                case num_args is
                    when  0 =>
                        result := new string'(fpr(fmt.all)) ;
                    when  1 =>
                        result := new string'(fpr(fmt.all, args(1).all)) ;
                    when  2 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all)) ;
                    when  3 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all)) ;
                    when  4 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all)) ;
                    when  5 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all)) ;
                    when  6 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all)) ;
                    when  7 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all)) ;
                    when  8 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all)) ;
                    when  9 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all,
                                                  args(9).all)) ;
                    when 10 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all,
                                                  args(9).all,
                                                  args(10).all)) ;
                    when 11 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all,
                                                  args(9).all,
                                                  args(10).all,
                                                  args(11).all)) ;
                    when 12 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all,
                                                  args(9).all,
                                                  args(10).all,
                                                  args(11).all,
                                                  args(12).all)) ;
                    when 13 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all,
                                                  args(9).all,
                                                  args(10).all,
                                                  args(11).all,
                                                  args(12).all,
                                                  args(13).all)) ;
                    when 14 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all,
                                                  args(9).all,
                                                  args(10).all,
                                                  args(11).all,
                                                  args(12).all,
                                                  args(13).all,
                                                  args(14).all)) ;
                    when 15 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all,
                                                  args(9).all,
                                                  args(10).all,
                                                  args(11).all,
                                                  args(12).all,
                                                  args(13).all,
                                                  args(14).all,
                                                  args(15).all)) ;
                    when 16 =>
                        result := new string'(fpr(fmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all,
                                                  args(9).all,
                                                  args(10).all,
                                                  args(11).all,
                                                  args(12).all,
                                                  args(13).all,
                                                  args(14).all,
                                                  args(15).all,
                                                  args(16).all)) ;
                    when others =>
                        report fpr("Too many arguments: {} > 16", f(num_args,"d"))
                            severity failure ;
                        result := new string'("") ;
                end case ;

            -------------------------------------------------------------------
            -- fproc
            -------------------------------------------------------------------
            elsif cmd.all = "fproc" then
                clear(args_list) ;
                for i in 1 to num_args loop
                    append(args_list, args(i).all) ;
                end loop ;
                fproc(fmt.all, args_list, result) ;

            -------------------------------------------------------------------
            -- freal
            -------------------------------------------------------------------
            elsif cmd.all = "freal" then
                read(args(1), real_arg, good) ;
                if good = false then
                    report "Invalid real argument: " & args(1).all
                        severity warning ;
                end if ;
                result := new string'(freal(real_arg, fmt.all)) ;
            -------------------------------------------------------------------
            -- fsfixed
            -------------------------------------------------------------------

            -------------------------------------------------------------------
            -- fsigned
            -------------------------------------------------------------------

            -------------------------------------------------------------------
            -- fslv
            -------------------------------------------------------------------

            -------------------------------------------------------------------
            -- fstr
            -------------------------------------------------------------------
            elsif cmd.all = "fstr" then
                result := new string'(fstr(args(1).all, fmt.all)) ;

            -------------------------------------------------------------------
            -- ftime
            -------------------------------------------------------------------
            elsif cmd.all = "ftime" then
                read(args(1), time_arg, good) ;
                if good = false then
                    report "Invalid time argument: " & args(1).all
                        severity warning ;
                    end if ;
                result := new string'(ftime(time_arg, fmt.all)) ;

            -------------------------------------------------------------------
            -- fufixed
            -------------------------------------------------------------------

            -------------------------------------------------------------------
            -- funsigned
            -------------------------------------------------------------------

            -------------------------------------------------------------------
            -- Unknown command
            -------------------------------------------------------------------
            else
                report fpr("Unknown command on line {}: {}", f(lineno, "d"), cmd.all) ;
            end if ;

            -- Increment test count
            tests := tests + 1 ;

            -- Check if result is null which is an error
            if result = null then
                failed := failed + 1 ;
                report "Result is null, skipping comparison"
                    severity warning ;
                next ;
            end if ;

            -- Check if gold is null which is an error
            if gold = null then
                failed := failed + 1 ;
                report "Gold is null, skipping comparison"
                    severity warning ;
                next ;
            end if ;

            -- Perform the actual comparison
            if result.all /= gold.all then
                failed := failed + 1 ;
                report fpr("Failure: '{}' /= '{}'", fstr(result.all,"s"), fstr(gold.all,"s"))
                    severity warning ;
            end if ;
        end loop ;

        -- Final report
        write(output, fpr("Tests: {}   Passed: {}   Failed: {}", f(tests, ">8d"), f(tests-failed, ">8d"), f(failed, ">8d")) & ENDL) ;

        -- Close the test file
        file_close(fin) ;

        -- Done
        std.env.stop ;
    end process ;

end architecture ;
