use std.textio.all ;

library ieee ;
    use ieee.std_logic_1164.all ;

library work ;
    use work.fmt.all ;
    use work.string_list.all ;

entity fmt_test is
  generic (
    FILEPATH    :   string := "./vectors/format_test_vectors.txt"
  ) ;
end entity ;

architecture arch of fmt_test is

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

    -- Define the custom type
    type state_t is (IDLE, CHECKING, FOO, BAR) ;
    signal state : state_t := CHECKING ;

    function to_string(x : state_t) return string is
    begin
        return state_t'image(x) ;
    end function ;

    -- VHDL-2008 required with generic subprograms
    --function f is new f generic map (t => state_t) ;

begin

    test : process
        type lines_t is array(positive range <>) of line ;
        type bit_vector_ptr is access bit_vector ;
        file fin            :   text ;
        variable fstatus    :   file_open_status ;
        variable l          :   line ;
        variable ll         :   line ;
        variable bit_arg    :   bit ;
        variable bv_ptr     :   bit_vector_ptr ;
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
        variable sfmt       :   line ;
        variable result     :   line ;
        variable gold       :   line ;
        variable args       :   lines_t(1 to 16) := (others => null) ;
        variable args_list  :   string_list ;
    begin
        -- Open the test file
        file_open(fin, FILEPATH, READ_MODE) ;

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
                report fmt("Invalid test at line {}: {}", f(lineno), l.all)
                    severity warning ;
                next ;
            end if ;

            -- Populate Command
            get(lines, 0, cmd) ;

            -- Populate Format String
            get(lines, 1, sfmt) ;

            -- Clear any old arguments
            args := (others => null) ;

            -- Populate the arguments
            for idx in 2 to 1+num_args loop
                -- Ensure we don't run over
                if idx-1 > args'length then
                    exit ;
                end if ;
                get(lines, idx, args(idx-1)) ;
            end loop ;

            -- Last line is always gold
            get(lines, len-1, gold) ;

            -- Process the different commands
            -------------------------------------------------------------------
            -- fb
            -------------------------------------------------------------------
            if cmd.all = "fb" then
                read(args(1), bit_arg, good) ;
                if good = false then
                    report fmt("Invalid bit argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(sfmt.all, bit_arg)) ;
                else
                    report "fb command requires a format string, none given"
                        severity warning ;
                    result := new string'("") ;
                end if ;

            -------------------------------------------------------------------
            -- fbv
            -------------------------------------------------------------------
            elsif cmd.all = "fbv" then
                bv_ptr := new bit_vector(0 to args(1)'length-1) ;
                bread(args(1), bv_ptr.all, good) ;
                if good = false then
                    report fmt("Invalid bit_vector argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(sfmt.all, bv_ptr.all)) ;
                else
                    report "fbv command requires a format string, none given"
                        severity warning ;
                    result := new string'("") ;
                end if ;

            -------------------------------------------------------------------
            -- fbit
            -------------------------------------------------------------------
            elsif cmd.all = "fbit" then
                read(args(1), bit_arg, good) ;
                if good = false then
                    report fmt("Invalid bit argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(bit_arg, sfmt.all)) ;
                else
                    result := new string'(f(bit_arg)) ;
                end if ;

            -------------------------------------------------------------------
            -- fbitvector
            -------------------------------------------------------------------
            elsif cmd.all = "fbitvector" then
                bv_ptr := new bit_vector(0 to l'length-1) ;
                read(args(1), bv_ptr.all, good) ;
                if good = false then
                    report fmt("Invalid bit_vector argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(bv_ptr.all, sfmt.all)) ;
                else
                    result := new string'(f(bv_ptr.all)) ;
                end if ;

            -------------------------------------------------------------------
            -- fbool
            -------------------------------------------------------------------
            elsif cmd.all = "fbool" then
                read(args(1), bool_arg, good) ;
                if good = false then
                    report fmt("Invalid bool argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(sfmt.all, bool_arg)) ;
                else
                    report "fbool command requires a format string, none given"
                        severity warning ;
                    result := new string'("") ;
                end if ;

            -------------------------------------------------------------------
            -- fboolean
            -------------------------------------------------------------------
            elsif cmd.all = "fboolean" then
                read(args(1), bool_arg, good) ;
                if good = false then
                    report fmt("Invalid bool argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(bool_arg, sfmt.all)) ;
                else
                    result := new string'(f(bool_arg)) ;
                end if ;

            -------------------------------------------------------------------
            -- fchar
            -------------------------------------------------------------------
            elsif cmd.all = "fchar" then
                read(args(1), char_arg, good) ;
                if good = false then
                    report fmt("Invalid character argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(char_arg, sfmt.all)) ;
                else
                    result := new string'(f(char_arg)) ;
                end if ;

            -------------------------------------------------------------------
            -- fi
            -------------------------------------------------------------------
            elsif cmd.all = "fi" then
                read(args(1), int_arg, good) ;
                if good = false then
                    report fmt("Invalid integer argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(sfmt.all, int_arg)) ;
                else
                    report "fi command requires a format string, none given"
                        severity warning ;
                    result := new string'("") ;
                end if ;

            -------------------------------------------------------------------
            -- fr
            -------------------------------------------------------------------
            elsif cmd.all = "fr" then
                read(args(1), real_arg, good) ;
                if good = false then
                    report fmt("Invalid real argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(sfmt.all, real_arg)) ;
                else
                    report "fr command requires a format string, none given"
                        severity warning ;
                    result := new string'("") ;
                end if ;

            -------------------------------------------------------------------
            -- ft
            -------------------------------------------------------------------
            elsif cmd.all = "ft" then
                read(args(1), time_arg, good) ;
                if good = false then
                    report fmt("Invalid time argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(sfmt.all, time_arg)) ;
                else
                    report "ft command requires a format string, none given"
                        severity warning ;
                    result := new string'("") ;
                end if ;

            -------------------------------------------------------------------
            -- fint
            -------------------------------------------------------------------
            elsif cmd.all = "fint" then
                read(args(1), int_arg, good) ;
                if good = false then
                    report fmt("Invalid integer argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(int_arg, sfmt.all)) ;
                else
                    result := new string'(f(int_arg)) ;
                end if ;

            -------------------------------------------------------------------
            -- fmt
            -------------------------------------------------------------------
            elsif cmd.all = "fmt" then
                case num_args is
                    when  0 =>
                        result := new string'(fmt(sfmt.all)) ;
                    when  1 =>
                        result := new string'(fmt(sfmt.all, args(1).all)) ;
                    when  2 =>
                        result := new string'(fmt(sfmt.all,
                                                  args(1).all,
                                                  args(2).all)) ;
                    when  3 =>
                        result := new string'(fmt(sfmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all)) ;
                    when  4 =>
                        result := new string'(fmt(sfmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all)) ;
                    when  5 =>
                        result := new string'(fmt(sfmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all)) ;
                    when  6 =>
                        result := new string'(fmt(sfmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all)) ;
                    when  7 =>
                        result := new string'(fmt(sfmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all)) ;
                    when  8 =>
                        result := new string'(fmt(sfmt.all,
                                                  args(1).all,
                                                  args(2).all,
                                                  args(3).all,
                                                  args(4).all,
                                                  args(5).all,
                                                  args(6).all,
                                                  args(7).all,
                                                  args(8).all)) ;
                    when  9 =>
                        result := new string'(fmt(sfmt.all,
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
                        result := new string'(fmt(sfmt.all,
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
                        result := new string'(fmt(sfmt.all,
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
                        result := new string'(fmt(sfmt.all,
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
                        result := new string'(fmt(sfmt.all,
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
                        result := new string'(fmt(sfmt.all,
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
                        result := new string'(fmt(sfmt.all,
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
                    when others =>
                        if num_args > 16 then
                            report fmt("Too many arguments on line {}: {} > 16, trimming to 16", f(lineno), f(num_args))
                                severity warning ;
                        end if ;
                        result := new string'(fmt(sfmt.all,
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
                end case ;

            -------------------------------------------------------------------
            -- fproc
            -------------------------------------------------------------------
            elsif cmd.all = "fproc" then
                -- Clear the args_list
                clear(args_list) ;

                -- Add the args to the args_list
                for idx in 2 to len-1-1 loop
                    get(lines, idx, l) ;
                    append(args_list, l.all) ;
                end loop ;

                -- Format
                f(sfmt.all, args_list, result) ;

            -------------------------------------------------------------------
            -- freal
            -------------------------------------------------------------------
            elsif cmd.all = "freal" then
                read(args(1), real_arg, good) ;
                if good = false then
                    report fmt("Invalid real argument: {}", args(1).all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    result := new string'(f(real_arg, sfmt.all)) ;
                else
                    result := new string'(f(real_arg)) ;
                end if ;

            -------------------------------------------------------------------
            -- fstr
            -------------------------------------------------------------------
            elsif cmd.all = "fstr" then
                if sfmt'length > 0 then
                    result := new string'(fstr(args(1).all, sfmt.all)) ;
                else
                    result := new string'(fstr(args(1).all)) ;
                end if ;

            -------------------------------------------------------------------
            -- ftime
            -------------------------------------------------------------------
            elsif cmd.all = "ftime" then
                read(args(1), time_arg, good) ;
                if good = false then
                    report fmt("Invalid time argument: {}", args(1).all)
                        severity warning ;
                    end if ;
                if sfmt'length > 0 then
                    result := new string'(f(time_arg, sfmt.all)) ;
                else
                    result := new string'(f(time_arg)) ;
                end if ;

            -------------------------------------------------------------------
            -- Unknown command
            -------------------------------------------------------------------
            else
                report fmt("Unknown command on line {}: {}", f(lineno), cmd.all) ;
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
                report f("Failure line {}: '{}' /= '{}'", f(lineno), fstr(result.all), fstr(gold.all))
                    severity warning ;
            end if ;
        end loop ;

        -- Final report
        write(output, fmt("Tests: {:>8d}   Passed: {:>8d}   Failed: {:>8d}" & LF, f(tests), f(tests-failed), f(failed))) ;

        -- Close the test file
        file_close(fin) ;

        -- VHDL-2008 required with generic subprograms
        --report fmt("state: {}", f(state, "->20s")) ;
        -- Alternative that doesn't require generic subprograms
        --report fmt("state: {}", fstr(state_t'image(state), "->20s")) ;

        -- Done
        std.env.stop ;
    end process ;

end architecture ;
