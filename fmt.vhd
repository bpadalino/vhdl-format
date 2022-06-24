library ieee ;
    use ieee.std_logic_1164.all ;

package fmt is

    -- TODO: Can this be a generic linked list?  Should it be in a different package?
    type string_list ;
    type string_list_item ;
    type string_list_item_ptr is access string_list_item ;

    type string_list is record
        root    :   string_list_item_ptr ;
        length  :   natural ;
    end record ;

    type string_list_item is record
        str         :   std.textio.line ;
        next_item   :   string_list_item_ptr ;
    end record ;

    type align_t is (LEFT, RIGHT, CENTERED, SIGN_EDGE) ;

    --  b       Binary
    --  c       Character
    --  d       Signed integer
    --  f       Floating point
    --  o       Octal
    --  s       String
    --  u       Unsigned integer
    --  x       Hexadecimal
    type class_t is (BINARY, CHAR, INT, FLOAT, OCTAL, STR, UINT, HEX) ;

    -- [fill][align][sign][width][.precision][class]
    -- NOTE: # after sign might be good for prefixes (0b, 0o, 0x) and might be easy to implement.
    -- NOTE: Grouping might be good, but python only limits to [,_] and doesn't allow for arbitrary
    -- grouping size.  Could be arbitrary character like fill, and how many digits?  Sounds complicated, though.
    type fmt_spec_t is record
        fill        :   character ;
        align       :   align_t ;
        sign        :   boolean ;
        width       :   natural ;
        precision   :   natural ;
        class       :   class_t ;
    end record ;

    constant DEFAULT_FMT_SPEC : fmt_spec_t := (
        fill        =>  ' ',
        align       =>  LEFT,
        sign        =>  false,
        width       =>  0,
        precision   =>  0,
        class       =>  BINARY
    ) ;

    function parse(fmt : string ; default_class : class_t := BINARY) return fmt_spec_t ;

    function to_side(value : align_t) return std.textio.side ;

    procedure fill(variable l : inout std.textio.line ; variable fmt_spec : fmt_spec_t ; variable fillcount : inout natural) ;

    ---------------------------------------------------------------------------
    -- VHDL-2008 Generic Function
    ---------------------------------------------------------------------------
    ---- TODO: Generic f() function which utilizes the type'image to get the string and just pass to fstr()?
    ---- Useful for custom enumerated types?
    --function f
    --    generic(type t; function to_string(x : t) return string is <>)
    --    parameter(value : t ; fmt : string := "s")
    --    return string ;

    procedure f(fmt : string ; variable args : inout string_list ; variable l : inout std.textio.line) ;
    alias fproc is f[string, string_list, std.textio.line] ;

    function f(fmt : string ; a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 : in string := "") return string ;
    alias fpr is f[string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string return string] ;

    -- Helper functions
    function f(value : bit ; fmt : string := "b") return string ;
    alias fbit is f[bit, string return string] ;

    --function f(value : bit_vector ; fmt : string) return string ;
    --alias fbv is f[bit_vector, string return string] ;

    function f(value : boolean ; fmt : string := "s") return string ;
    alias fbool is f[boolean, string return string] ;

    function f(value : character ; fmt : string := "c") return string ;
    alias fchar is f[character, string return string] ;

    function f(value : integer ; fmt : string := "d") return string ;
    alias fint is f[integer, string return string] ;

    function f(value : real ; fmt : string := "f") return string ;
    alias freal is f[real, string return string] ;

    --function f(value : signed ; fmt : string) return string ;
    -- alias fsigned is f[signed, string return string] ;

    function f(value : string ; fmt : string := "s") return string ;
    alias fstr is f[string, string return string] ;

    function f(value : time ; fmt : string := ".9f") return string ;
    alias ftime is f[time, string return string] ;

    --function f(value : std_logic ; fmt : string) return string ;
    function f(value : std_logic_vector ; fmt : string := "b" ) return string ;
    alias fslv is f[std_logic_vector, string return string] ;

    --function f(value : unsigned ; fmt : string) return string ;
    --alias funsigned is f[unsigned, string return string] ;

    procedure append(variable list : inout string_list ; s : string) ;
    --procedure replace(variable list : inout string_list ; index : integer ; s : string) ;
    procedure clear(variable list : inout string_list) ;
    procedure get(variable list : in string_list ; index : integer ; variable l : out std.textio.line) ;
    procedure length(variable list : string_list; variable len : out natural) ;

end package ;

package body fmt is

    ---------------------------------------------------------------------------
    -- VHDL-2008 Generic Function
    ---------------------------------------------------------------------------
    --function f
    --    generic(type t; function to_string(x : t) return string is <>)
    --    parameter(value : t ; fmt : string := "s")
    --    return string
    --is
    --begin
    --    return fstr(to_string(value), fmt) ;
    --end function ;

    function to_integer(val : string) return integer is
        alias x : string(1 to val'length) is val ;
        variable rv : integer := 0 ;
    begin
        for i in x'range loop
            case x(i) is
                when '0' => rv := rv * 10 ; rv := rv + 0 ;
                when '1' => rv := rv * 10 ; rv := rv + 1 ;
                when '2' => rv := rv * 10 ; rv := rv + 2 ;
                when '3' => rv := rv * 10 ; rv := rv + 3 ;
                when '4' => rv := rv * 10 ; rv := rv + 4 ;
                when '5' => rv := rv * 10 ; rv := rv + 5 ;
                when '6' => rv := rv * 10 ; rv := rv + 6 ;
                when '7' => rv := rv * 10 ; rv := rv + 7 ;
                when '8' => rv := rv * 10 ; rv := rv + 8 ;
                when '9' => rv := rv * 10 ; rv := rv + 9 ;
                when others =>
                    report "Invalid character" severity warning ;
            end case ;
        end loop ;
        return rv ;
    end function ;

    function parse(fmt : string ; default_class : class_t := BINARY) return fmt_spec_t is
        alias fn : string(1 to fmt'length) is fmt ;
        type fsm_t is (START, FILL, ALIGN, SIGN, WIDTH, DOT, PRECISION, CLASS, EXTRA) ;
        variable fsm : fsm_t := START ;
        variable rv : fmt_spec_t := DEFAULT_FMT_SPEC ;
        variable idx : positive := 1 ;
        variable numstart : natural := 0 ;
        variable numstop : natural := 0 ;
        variable precision_present : boolean := false ;
    begin
        assert fn'length > 0
            report "Format string must not be empty"
                severity warning ;
        rv.class := default_class ;
        while idx <= fn'length loop
            --std.textio.write(std.textio.output, "idx: " & integer'image(idx) & " state: " & fsm_t'image(fsm) & " " & fn(idx) & CR & LF);
            case fsm is
                when START =>
                    if fn'length = 1 then
                        -- Only a single character
                        -- Default values
                        case fn(idx) is
                            when '<'|'>'|'^'|'=' =>
                                -- Alignment but it doesn't matter since no width
                                null ;

                            when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                                -- Single character width
                                fsm := WIDTH ;

                            when '+' =>
                                -- Sign
                                rv.sign := true ;

                            when 'b'|'B'|'c'|'C'|'d'|'D'|'f'|'F'|'o'|'O'|'s'|'S'|'u'|'U'|'x'|'X' =>
                                -- Class
                                fsm := CLASS ;

                            when '.' =>
                                -- Illegal precision
                                report "Format specifier missing precision"
                                    severity warning ;
                                exit ;

                            when others =>
                                report fstr("Unknown format code: {}", f(fn(idx)))
                                    severity warning ;
                                exit ;
                        end case ;
                    else
                        -- Guaranteed to be at least 2 characters
                        case fn(idx) is
                            -- Check the first character class
                            when '<'|'>'|'^'|'=' =>
                                -- Alignment character first, but could also be a fill character
                                case fn(idx+1) is
                                    when '<'|'>'|'^'|'=' =>
                                        -- 2 alignment characters in a row, so one must be for filling
                                        fsm := FILL ;
                                    when others =>
                                        -- Alignment character is first, followed by a non-alignment character
                                        fsm := ALIGN ;
                                end case ;

                            when '+' =>
                                -- Sign character first, but might be fill, check for alignment character next
                                case fn(idx+1) is
                                    when '<'|'>'|'^'|'=' =>
                                        -- Alignment character second, so consume FILL character
                                        fsm := FILL ;
                                    when others =>
                                        -- Second character is not an alignment character
                                        -- Assume first character is alignment and not fill
                                        fsm := SIGN ;
                                end case ;

                            when '0' =>
                                -- With a leading zero, either FILL or WIDTH
                                case fn(idx+1) is
                                    when '+'|'.' =>
                                        fsm := WIDTH ;
                                    when others =>
                                        fsm := FILL ;
                                end case ;

                            when '1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                                case fn(idx+1) is
                                    when '<'|'>'|'^'|'='|'+' =>
                                        -- Non-Zero number followed by alignment character or sign, so consume as fill character
                                        fsm := FILL ;
                                    when others =>
                                        -- Non-Zero number followed by something else, so assume width
                                        fsm := WIDTH ;
                                end case ;

                            when '.' =>
                                -- Start with DOT precision
                                fsm := DOT ;

                            when others =>
                                case fn(idx+1) is
                                    when '<'|'>'|'^'|'=' =>
                                        -- Alignment character is second, so fill character is first
                                        fsm := FILL ;

                                    when others =>
                                        report fpr("Invalid format specifier: {}", fstr(fn))
                                            severity warning ;
                                        exit ;
                                end case ;

                        end case ;
                    end if ;
                    next ;

                when FILL =>
                    rv.fill := fn(idx) ;
                    idx := idx + 1 ;
                    fsm := ALIGN ;
                    next ;

                when ALIGN =>
                    case fn(idx) is
                        when '<' =>
                            rv.align := LEFT ;
                            idx := idx + 1 ;
                        when '>' =>
                            rv.align := RIGHT ;
                            idx := idx + 1 ;
                        when '^' =>
                            rv.align := CENTERED ;
                            idx := idx + 1 ;
                        when '=' =>
                            rv.align := SIGN_EDGE ;
                            idx := idx + 1 ;
                        when others =>
                            null ;
                    end case ;
                    fsm := SIGN ;

                when SIGN =>
                    case fn(idx) is
                        when '+' =>
                            rv.sign := true ;
                            idx := idx + 1 ;

                        when others =>
                            null ;
                    end case ;
                    fsm := WIDTH ;

                when WIDTH =>
                    case fn(idx) is
                        when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                            if numstart = 0 then
                                numstart := idx ;
                                numstop := idx ;
                            elsif numstart > 0 then
                                numstop := idx ;
                            end if ;
                            idx := idx + 1 ;
                        when others =>
                            if numstart > 0 then
                                rv.width := to_integer(fn(numstart to numstop)) ;
                                numstart := 0 ;
                                numstop := 0 ;
                            end if ;
                            fsm := DOT ;
                    end case ;

                when DOT =>
                    case fn(idx) is
                        when '.' =>
                            idx := idx + 1 ;
                            fsm := PRECISION ;
                        when others =>
                            fsm := CLASS ;
                    end case ;

                when PRECISION =>
                    case fn(idx) is
                        when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                            if numstart = 0 then
                                numstart := idx ;
                                numstop := idx ;
                            elsif numstart > 0 then
                                numstop := idx ;
                            end if ;
                            idx := idx + 1 ;
                        when others =>
                            if numstart > 0 then
                                rv.precision := to_integer(fn(numstart to numstop)) ;
                                precision_present := true ;
                                numstart := 0 ;
                                numstop := 0 ;
                            else
                                report "Format specifier missing precision"
                                    severity warning ;
                            end if ;
                            fsm := CLASS ;
                    end case ;

                when CLASS =>
                    case fn(idx) is
                        when 'b'|'B' =>
                            rv.class := BINARY ;
                        when 'c'|'C' =>
                            rv.class := CHAR ;
                        when 'd'|'D' =>
                            rv.class := INT ;
                        when 'f'|'F' =>
                            if precision_present = true and rv.precision = 0 then
                                -- Precision was specified, so change the class to int to cut off
                                -- any decimal representation
                                rv.class := INT ;
                            else
                                rv.class := FLOAT ;
                            end if ;
                        when 'o'|'O' =>
                            rv.class := OCTAL ;
                        when 's'|'S' =>
                            rv.class := STR ;
                        when 'u'|'U' =>
                            rv.class := UINT ;
                        when 'x'|'X' =>
                            rv.class := HEX ;
                        when others =>
                            rv.class := BINARY ;
                            report fpr("Unknown class: {} is not [bcdofsux] - defaulting to BINARY", f(fn(idx)))
                                severity warning ;
                    end case ;
                    idx := idx + 1 ;
                    fsm := EXTRA ;

                when EXTRA =>
                    report fpr("Extra characters in format specifier ignored : {}",  fstr(fn(idx to fn'length)))
                        severity warning ;
                    exit ;

            end case ;
        end loop ;
        case fsm is
            when WIDTH =>
                rv.width := to_integer(fmt(numstart to numstop)) ;
            when PRECISION =>
                rv.width := to_integer(fmt(numstart to numstop)) ;
            when others =>
                null ;
        end case ;
        return rv ;
    end function ;

    function to_string(fmt_spec : fmt_spec_t) return string ;

    procedure shift(variable l : inout std.textio.line ; shift : in natural) is
        variable newl : std.textio.line := new string'(l.all) ;
        variable dest : positive := shift + 1 ;
    begin
        for idx in l'range loop
            newl(dest) := l(idx) ;
            dest := dest + 1 ;
            if dest = l'length + 1 then
                dest := 1 ;
            end if ;
        end loop ;
        l := newl ;
    end procedure ;

    function to_side(value : align_t) return std.textio.side is
    begin
        case value is
            when RIGHT|SIGN_EDGE =>
                return std.textio.right ;
            when others =>
                return std.textio.left ;
        end case ;
    end function ;

    procedure fill(variable l : inout std.textio.line ; variable fmt_spec : fmt_spec_t ; variable fillcount : inout natural) is
        variable inc : integer ;
        variable idx : integer ;
    begin
        fillcount := 0 ;
        case fmt_spec.align is
            when RIGHT|SIGN_EDGE =>
                -- Start on the left side to fill in
                idx := 1 ;
                inc := 1 ;
            when others =>
                -- Start on the right side to fill in
                idx := l'length ;
                inc := -1 ;
        end case ;
        while true loop
            if l(idx) = ' ' then
                fillcount := fillcount + 1 ;
                l(idx) := fmt_spec.fill ;
                idx := idx + inc ;
            else
                exit ;
            end if ;
        end loop ;
    end procedure ;

    function f(value : string ; fmt : string := "s") return string is
        alias s : string(1 to value'length) is value ;
        variable fmt_spec : fmt_spec_t := parse(fmt, STR) ;
        variable l : std.textio.line ;
        variable fillcount : natural ;
    begin
        if (fmt_spec.precision > 0) and (value'length > fmt_spec.precision) then
            -- Limiting the string size based on precision
            return s(1 to fmt_spec.precision) ;
        else
            std.textio.write(l, s, to_side(fmt_spec.align), fmt_spec.width) ;
        end if ;
        if fmt_spec.fill /= ' ' then
            fill(l, fmt_spec, fillcount) ;
        end if ;
        if fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        return l.all ;
    end function ;

    procedure print_fmt_spec(fmt : string ; fmt_spec : fmt_spec_t) is
    begin
        std.textio.write(std.textio.output, f("fmt_spec({}): {}" & CR & LF, fstr(fmt, ">10s"), to_string(fmt_spec))) ;
    end procedure ;


    function f(value : align_t ; fmt : string) return string is
        constant s : string := align_t'image(value) ;
    begin
        return fstr(s, fmt) ;
    end function ;

    function f(value : std_logic_vector ; fmt : string := "b") return string is
        variable fmt_spec : fmt_spec_t := parse(fmt) ;
        variable l : std.textio.line ;
    begin
        case fmt_spec.class is
            when BINARY =>
                ieee.std_logic_1164.write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
            when OCTAL =>
                ieee.std_logic_1164.owrite(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
            when HEX =>
                ieee.std_logic_1164.hwrite(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
            when others =>
                report "Unsure what to do here"
                    severity warning ;
        end case ;
        return l.all ;
    end function ;

    function f(value : class_t ; fmt : string) return string is
        constant s : string := class_t'image(value) ;
    begin
        return fstr(s, fmt) ;
    end function ;

    function to_string(fmt_spec : fmt_spec_t) return string is
    begin
        return f("fill: '{}'   align: {}   sign: {}   width: {}   precision: {}   class: {}",
                    f(fmt_spec.fill, ">1"),
                    f(fmt_spec.align, ">10"),
                    f(fmt_spec.sign, ">6"),
                    f(fmt_spec.width, ">4"),
                    f(fmt_spec.precision, ">4"),
                    f(fmt_spec.class, ">8")
                ) ;
    end function ;


    function f(value : bit ; fmt : string := "b") return string is
        variable fmt_spec : fmt_spec_t := parse(fmt, BINARY) ;
        variable l : std.textio.line ;
    begin
        std.textio.write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        return l.all ;
    end function ;

    function f(value : boolean ; fmt : string := "s") return string is
        variable fmt_spec : fmt_spec_t := parse(fmt, BINARY) ;
        variable l : std.textio.line ;
    begin
        std.textio.write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        return l.all ;
    end function ;

    function f(value : character ; fmt : string := "c") return string is
        variable fmt_spec : fmt_spec_t := parse(fmt, CHAR) ;
        variable l : std.textio.line ;
    begin
        std.textio.write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        return l.all ;
    end function ;

    function f(value : time ; fmt : string := ".9f" ) return string is
        variable fmt_spec : fmt_spec_t := parse(fmt, FLOAT) ;
        variable l : std.textio.line ;
        variable unit : time := 1 sec ;
        variable fillcount : natural ;
    begin
        case fmt_spec.precision is
            when 0  => unit := 1 sec ;
            when 3  => unit := 1 ms ;
            when 6  => unit := 1 us ;
            when 9  => unit := 1 ns ;
            when 12 => unit := 1 ps ;
            when 15 => unit := 1 fs ;
            when others =>
                report fpr("Time precision unknown: {}", f(fmt_spec.precision))
                    severity warning ;
        end case ;
        std.textio.write(l, value, to_side(fmt_spec.align), fmt_spec.width, unit) ;
        fill(l, fmt_spec, fillcount) ;
        if fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        return l.all ;
    end function ;

    procedure add_sign(variable l : inout std.textio.line ; s : character ; fmt_fill : character ) is
        variable idx : natural := 1 ;
    begin
        while l(idx) = fmt_fill loop
            idx := idx + 1 ;
        end loop ;
        l(idx-1) := s ;
    end procedure ;

    function f(value : integer ; fmt : string := "d") return string is
        variable fmt_spec : fmt_Spec_t := parse(fmt, INT) ;
        variable l : std.textio.line ;
        variable temp : std.textio.line ;
        variable fillcount : natural ;
        variable sign : character ;
    begin
        std.textio.write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        fill(l, fmt_spec, fillcount) ;
        if fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        if fmt_spec.sign = true then
            if fmt_spec.width = 0 then
                std.textio.write(temp, l.all, std.textio.right, l'length+1) ;
                l := temp ;
            else
                -- Has a specific size, so shift it over only if there isn't fill at the start
                if l(1) /= fmt_spec.fill then
                    shift(l, 1) ;
                end if ;
            end if ;
            if fmt_spec.align = SIGN_EDGE or fmt_spec.width = 0 then
                if value < 0 then
                    l(1) := '-' ;
                else
                    l(1) := '+' ;
                end if ;
            else
                if value < 0 then
                    sign := '-' ;
                else
                    sign := '+' ;
                end if ;
                add_sign(l, sign, fmt_spec.fill) ;
            end if ;
        end if ;
        --case fmt_spec.class is
        --    when BINARY =>
        --        return f(ieee.std_logic_1164.std_logic_vector(ieee.numeric_std.to_unsigned(value, fmt_spec.width)), fmt) ;
        --    when OCTAL =>
        --        return f(ieee.std_logic_1164.std_logic_vector(ieee.numeric_std.to_unsigned(value, fmt_spec.width*3)), fmt) ;
        --    when HEX =>
        --        return f(ieee.std_logic_1164.std_logic_vector(ieee.numeric_std.to_unsigned(value, fmt_spec.width*4)), fmt) ;
        --    when INT|UINT =>
        --        std.textio.write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        --    when others =>
        --        report "Unsure what to do here"
        --            severity warning ;
        --end case ;
        return l.all ;
    end function ;

    function f(value : real ; fmt : string := "f") return string is
        variable fmt_spec : fmt_spec_t := parse(fmt, FLOAT) ;
        variable l : std.textio.line ;
        variable temp : std.textio.line ;
        variable fillcount : natural ;
        variable sign : character ;
    begin
        if fmt_spec.class = INT then
            -- Cast to an integer
            return f(integer(value), fmt) ;
        end if ;
        --print_fmt_spec(fmt, fmt_spec) ;
        std.textio.write(l, value, to_side(fmt_spec.align), fmt_spec.width, fmt_spec.precision) ;
        fill(l, fmt_spec, fillcount) ;
        if fmt_spec.align = CENTERED then
            -- Circularly shift the filled output
            shift(l, fillcount/2) ;
        end if ;
        if fmt_spec.align = SIGN_EDGE then
            if (l(1) /= fmt_spec.fill) or (fmt_spec.width = 0) then
                std.textio.write(temp, l.all, std.textio.right, l'length+1) ;
                l := temp ;
            end if ;
            if value >= 0.0 then
                l(1) := '+' ;
            else
                l(1) := '-' ;
            end if ;
        elsif fmt_spec.sign = true then
            if value >= 0.0 then
                sign := '+' ;
            else
                sign := '-' ;
            end if ;
            if fmt_spec.width = 0 then
                std.textio.write(temp, l.all, std.textio.right, l'length+1) ;
                l := temp ;
            else
                if fmt_spec.align = LEFT then
                    shift(l, 1) ;
                end if ;
            end if ;
            if fmt_spec.align = LEFT then
                l(1) := sign ;
            else
                if l(1) /= fmt_spec.fill then
                    std.textio.write(temp, l.all, std.textio.right, l'length+1) ;
                    l := temp ;
                end if ;
                add_sign(l, sign, fmt_spec.fill) ;
            end if ;
        end if ;
        return l.all ;
    end function ;


    procedure append(variable list : inout string_list ; s : string) is
        variable l          : std.textio.line := new string'(s) ;
        variable new_item   : string_list_item_ptr := new string_list_item ;
        variable item       : string_list_item_ptr := list.root ;
    begin
        new_item.str := l ;
        new_item.next_item := null ;
        if list.length = 0 then
            list.root := new_item ;
        else
            while item.next_item /= null loop
                item := item.next_item ;
            end loop ;
            item.next_item := new_item ;
        end if ;
        list.length := list.length + 1 ;
    end procedure ;

    procedure clear(variable list : inout string_list) is
        variable item       : string_list_item_ptr := list.root ;
        variable next_item  : string_list_item_ptr := null ;
    begin
        if item /= null then
            next_item := item.next_item ;
        end if ;
        while item /= null loop
            next_item := item.next_item ;
            deallocate(item) ;
            item := next_item ;
        end loop ;
        list.root := null ;
        list.length := 0 ;
    end procedure ;

    procedure get(variable list : in string_list ; index : integer ; variable l : out std.textio.line) is
        variable item : string_list_item_ptr := list.root ;
    begin
        if index >= list.length then
            report "Cannot retrieve item, index out of bounds"
                severity warning ;
            l := null ;
        end if ;
        for i in 1 to index loop
            item := item.next_item ;
        end loop ;
        l := item.str ;
    end procedure ;

    procedure length(variable list : string_list; variable len : out natural) is
    begin
        len := list.length ;
    end procedure ;

    procedure create_parts(fn : string ; variable parts : inout string_list ; variable args : inout string_list) is
        type fsm_t is (COPY_STRING, LBRACE, RBRACE, READ_ARGNUM) ;
        variable fsm            : fsm_t := COPY_STRING ;
        variable start          : positive ;
        variable stop           : positive ;
        variable argnum         : integer := 0 ;
        variable numstart       : positive ;
        variable numstop        : positive ;
        variable argnum_used    : boolean := false ;
        variable len            : natural ;
        variable l              : std.textio.line ;
    begin
        start := 1 ;
        stop  := 1 ;
        for i in fn'range loop
            case fsm is
                when COPY_STRING =>
                    case fn(i) is
                        when '{' =>
                            if i /= 1 then
                                -- Copy the current simple string to the parts
                                append(parts, fn(start to stop)) ;
                            end if ;

                            -- Parse the {
                            fsm := LBRACE ;
                        when '}' =>
                            if i /= 1 then
                                -- Copy the simple string to the parts
                                append(parts, fn(start to stop)) ;
                            end if ;

                            -- Parse the }
                            fsm := RBRACE ;
                        when others =>
                            stop := i ;
                    end case ;

                when LBRACE =>
                    case fn(i) is
                        when '{' =>
                            -- {{ so just add a single {
                            append(parts, "{") ;

                            -- Start a new piece on the next character
                            start := i + 1 ;
                            stop := i ;
                            fsm := COPY_STRING ;

                        when '}' =>
                            -- {} so add the next argument to the piecs

                            -- Add the next argument to the parts
                            length(args, len) ;
                            assert argnum <= len
                                report f("Too many arguments given the list: {} > {}", f(argnum), f(len))
                                severity warning ;
                            assert argnum_used = false
                                report "Cannot mix argnum usage in format string"
                                severity warning ;
                            if argnum >= len then
                                argnum := len - 1 ;
                            end if ;
                            get(args, argnum, l) ;
                            append(parts, l.all) ;
                            argnum := argnum + 1 ;

                            -- New start position on next character
                            start := i + 1 ;
                            stop := i ;
                            fsm := COPY_STRING ;

                        when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                            -- A number to read to get the argument we want
                            numstart := i ;
                            numstop := i ;
                            fsm := READ_ARGNUM ;
                            argnum_used := true ;

                        when others =>
                            report f("Invalid character inside formatter at position {}: {}", f(i), f(fn(i)))
                                severity warning ;
                    end case ;

                when RBRACE =>
                    case fn(i) is
                        when '}' =>
                            -- }} so remove one of them
                            append(parts, "}") ;

                            -- Start a new piece on the next character
                            start := i + 1 ;
                            stop := i ;
                            fsm := COPY_STRING ;

                        when others =>
                            report fpr("Parsing error, RBRACE without corresponding LBRACE or RBRACE at {}: {}", f(i-1), fstr(fn))
                                severity warning ;
                    end case ;

                when READ_ARGNUM =>
                    case fn(i) is
                        when '}' =>
                            argnum := to_integer(fn(numstart to numstop)) ;
                            length(args, len) ;
                            assert argnum < len
                                report f("Invalid argnum ({}) - total arguments: {}", f(argnum), f(len))
                                severity warning ;

                            -- Append the argument
                            if argnum >= len then
                                argnum := len - 1 ;
                            end if ;
                            get(args, argnum, l) ;
                            append(parts, l.all) ;

                            -- Start the next piece
                            fsm := COPY_STRING ;
                            start := i + 1 ;
                            stop := i ;

                        when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                            numstop := i ;

                        when others =>
                            report f("Invalid argument specifier ({}) at position {}", f(fn(i)), f(i))
                                severity warning ;

                    end case ;
            end case ;
        end loop ;

        -- Add the final bit
        append(parts, fn(start to stop) ) ;

        if argnum_used = false then
            length(args, len) ;
            if argnum /= len then
                report f("Extra arguments passed into format expression - passed {}, but used {}", f(len), f(argnum))
                    severity warning ;
            end if ;
        end if ;
    end procedure ;

    procedure sumlength(variable list : string_list ; rv : out natural) is
        variable l : std.textio.line := null ;
        variable len : natural ;
        variable count : natural := 0 ;
    begin
        length(list, len) ;
        for i in 0 to len-1 loop
            get(list, i, l) ;
            count := count + l.all'length ;
        end loop ;
        rv := count ;
    end procedure ;

    procedure concatenate_list(variable parts : string_list ; variable rv : inout std.textio.line) is
        variable start : positive := 1 ;
        variable stop : positive := 1 ;
        variable l : std.textio.line ;
        variable len : natural ;
    begin
        sumlength(parts, len) ;
        rv := new string(1 to len) ;
        for i in 0 to parts.length-1 loop
            get(parts, i, l) ;
            stop := start + l.all'length - 1 ;
            rv(start to stop) := l.all ;
            start := stop + 1 ;
        end loop ;
    end procedure ;

    function f(fmt : string ; a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 : in string := "") return string is
        -- Normalize the format string
        alias fn : string(1 to fmt'length) is fmt ;

        -- Arguments and parts of the strings to put together
        variable args   : string_list ;
        variable parts  : string_list ;

        -- Add the arguments to the string_list only if the argument isn't null
        procedure add_args is
            variable len : natural ;
        begin
            length(parts, len) ;
            assert len = 0 ;
            length(parts, len) ;
            assert len = 0 ;
            if a0'length = 0  then return ; else append(args, a0)  ; end if ;
            if a1'length = 0  then return ; else append(args, a1)  ; end if ;
            if a2'length = 0  then return ; else append(args, a2)  ; end if ;
            if a3'length = 0  then return ; else append(args, a3)  ; end if ;
            if a4'length = 0  then return ; else append(args, a4)  ; end if ;
            if a5'length = 0  then return ; else append(args, a5)  ; end if ;
            if a6'length = 0  then return ; else append(args, a6)  ; end if ;
            if a7'length = 0  then return ; else append(args, a7)  ; end if ;
            if a8'length = 0  then return ; else append(args, a8)  ; end if ;
            if a9'length = 0  then return ; else append(args, a9)  ; end if ;
            if a10'length = 0 then return ; else append(args, a10) ; end if ;
            if a11'length = 0 then return ; else append(args, a11) ; end if ;
            if a12'length = 0 then return ; else append(args, a12) ; end if ;
            if a13'length = 0 then return ; else append(args, a13) ; end if ;
            if a14'length = 0 then return ; else append(args, a14) ; end if ;
            if a15'length = 0 then return ; else append(args, a15) ; end if ;
        end procedure ;

        variable l : std.textio.line ;
    begin
        -- Zero length format string short circuit
        if fn'length = 0 then
            return "" ;
        end if ;

        -- Set the arguments for the formatter
        add_args ;

        -- Create parts to concatenate removing the formatting
        create_parts(fn, parts, args) ;

        -- Return the concatenated parts
        concatenate_list(parts, l) ;
        return l.all ;
    end function ;

    procedure f(fmt : string ; variable args : inout string_list ; variable l : inout std.textio.line) is
        alias fn : string(1 to fmt'length) is fmt ;
        variable parts : string_list ;
    begin
        -- Zero length format string short circuit
        if fn'length = 0 then
            l := new string'("") ;
        end if ;

        -- Create parts to concatenate removing the formatting
        create_parts(fn, parts, args) ;

        -- Return the concatenated parts
        concatenate_list(parts, l) ;
    end procedure ;

end package body ;

