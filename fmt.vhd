-- Package: colors
-- Description
--  A package containing the strings for producing ANSI colored output on a
--  terminal.

package colors is
    type colors_t is record
        BLACK   :   string ;
        RED     :   string ;
        GREEN   :   string ;
        YELLOW  :   string ;
        BLUE    :   string ;
        PURPLE  :   string ;
        CYAN    :   string ;
        WHITE   :   string ;
    end record ;

    type ansi_t is record
        -- Foreground colors, typical
        BLACK       :   string ;
        RED         :   string ;
        GREEN       :   string ;
        YELLOW      :   string ;
        BLUE        :   string ;
        PURPLE      :   string ;
        CYAN        :   string ;
        WHITE       :   string ;

        -- More styles
        bold        :   colors_t ;
        underline   :   colors_t ;
        intense     :   colors_t ;
        boldintense :   colors_t ;
        -- Background colors
        background  :   colors_t ;
        intensebg   :   colors_t ;

        -- Control sequence
        RESET       :   string ;
    end record ;

    constant FOREGROUND_COLORS : colors_t := (
        BLACK       =>  (ESC & "[30m"),
        RED         =>  (ESC & "[31m"),
        GREEN       =>  (ESC & "[32m"),
        YELLOW      =>  (ESC & "[33m"),
        BLUE        =>  (ESC & "[34m"),
        PURPLE      =>  (ESC & "[35m"),
        CYAN        =>  (ESC & "[36m"),
        WHITE       =>  (ESC & "[37m")
    ) ;

    constant BOLD_COLORS : colors_t := (
        BLACK       =>  (ESC & "[1;30m"),
        RED         =>  (ESC & "[1;31m"),
        GREEN       =>  (ESC & "[1;32m"),
        YELLOW      =>  (ESC & "[1;33m"),
        BLUE        =>  (ESC & "[1;34m"),
        PURPLE      =>  (ESC & "[1;35m"),
        CYAN        =>  (ESC & "[1;36m"),
        WHITE       =>  (ESC & "[1;37m")
    ) ;

    constant UNDERLINE_COLORS : colors_t := (
        BLACK       =>  (ESC & "[4;30m"),
        RED         =>  (ESC & "[4;31m"),
        GREEN       =>  (ESC & "[4;32m"),
        YELLOW      =>  (ESC & "[4;33m"),
        BLUE        =>  (ESC & "[4;34m"),
        PURPLE      =>  (ESC & "[4;35m"),
        CYAN        =>  (ESC & "[4;36m"),
        WHITE       =>  (ESC & "[4;37m")
    ) ;

    constant BACKGROUND_COLORS : colors_t := (
        BLACK       =>  (ESC & "[40m"),
        RED         =>  (ESC & "[41m"),
        GREEN       =>  (ESC & "[42m"),
        YELLOW      =>  (ESC & "[43m"),
        BLUE        =>  (ESC & "[44m"),
        PURPLE      =>  (ESC & "[45m"),
        CYAN        =>  (ESC & "[46m"),
        WHITE       =>  (ESC & "[47m")
    ) ;

    constant INTENSE_COLORS : colors_t := (
        BLACK       =>  (ESC & "[0;90m"),
        RED         =>  (ESC & "[0;91m"),
        GREEN       =>  (ESC & "[0;92m"),
        YELLOW      =>  (ESC & "[0;93m"),
        BLUE        =>  (ESC & "[0;94m"),
        PURPLE      =>  (ESC & "[0;95m"),
        CYAN        =>  (ESC & "[0;96m"),
        WHITE       =>  (ESC & "[0;97m")
    ) ;

    constant BOLD_INTENSE_COLORS : colors_t := (
        BLACK       =>  (ESC & "[1;90m"),
        RED         =>  (ESC & "[1;91m"),
        GREEN       =>  (ESC & "[1;92m"),
        YELLOW      =>  (ESC & "[1;93m"),
        BLUE        =>  (ESC & "[1;94m"),
        PURPLE      =>  (ESC & "[1;95m"),
        CYAN        =>  (ESC & "[1;96m"),
        WHITE       =>  (ESC & "[1;97m")
    ) ;


    constant INTENSE_BACKGROUND_COLORS : colors_t := (
        BLACK       =>  (ESC & "[0;100m"),
        RED         =>  (ESC & "[0;101m"),
        GREEN       =>  (ESC & "[0;102m"),
        YELLOW      =>  (ESC & "[0;103m"),
        BLUE        =>  (ESC & "[0;104m"),
        PURPLE      =>  (ESC & "[0;105m"),
        CYAN        =>  (ESC & "[0;106m"),
        WHITE       =>  (ESC & "[0;107m")
    ) ;

    constant ansi   : ansi_t := (
        BLACK       =>  FOREGROUND_COLORS.BLACK,
        RED         =>  FOREGROUND_COLORS.RED,
        GREEN       =>  FOREGROUND_COLORS.GREEN,
        YELLOW      =>  FOREGROUND_COLORS.YELLOW,
        BLUE        =>  FOREGROUND_COLORS.BLUE,
        PURPLE      =>  FOREGROUND_COLORS.PURPLE,
        CYAN        =>  FOREGROUND_COLORS.CYAN,
        WHITE       =>  FOREGROUND_COLORS.WHITE,
        bold        =>  BOLD_COLORS,
        underline   =>  UNDERLINE_COLORS,
        intense     =>  INTENSE_COLORS,
        boldintense =>  BOLD_INTENSE_COLORS,
        background  =>  BACKGROUND_COLORS,
        intensebg   =>  INTENSE_BACKGROUND_COLORS,
        RESET       =>  (ESC & "[0m")
    ) ;

end package ;

-- Package: string_list
-- Description
--  A string_list is a dynamic array of strings which can efficiently be passed
--  between procedures such that the string does not need to be the same length.
-- NOTE
--  In the future, I'd like this to be a generic list package.  If this is the
--  case then string_list can just be an instantiation of the generic list.
--  The only extra procedures to write are then sumlength and concatenate_list.
use std.textio.line ;

package string_list is

    type string_list ;
    type string_list_item ;
    type string_list_item_ptr is access string_list_item ;

    type string_list is record
        root    :   string_list_item_ptr ;
        length  :   natural ;
    end record ;

    type string_list_item is record
        str         :   line ;
        next_item   :   string_list_item_ptr ;
    end record ;

    -- Procedures for manipulating string_list
    procedure append(variable list : inout string_list ; s : string) ;
    procedure clear(variable list : inout string_list) ;
    procedure get(variable list : in string_list ; index : integer ; variable l : out line) ;
    procedure length(variable list : string_list; variable len : out natural) ;
    procedure sumlength(variable list : string_list ; rv : out natural) ;
    procedure concatenate_list(variable parts : string_list ; variable rv : inout line) ;

end package ;

package body string_list is

    procedure append(variable list : inout string_list ; s : string) is
        variable l          : line                  := new string'(s) ;
        variable new_item   : string_list_item_ptr  := new string_list_item ;
        variable item       : string_list_item_ptr  := list.root ;
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

    procedure get(variable list : in string_list ; index : integer ; variable l : out line) is
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

    procedure sumlength(variable list : string_list ; rv : out natural) is
        variable l      : line      := null ;
        variable len    : natural   := 0 ;
        variable count  : natural   := 0 ;
    begin
        length(list, len) ;
        for i in 0 to len-1 loop
            get(list, i, l) ;
            count := count + l.all'length ;
        end loop ;
        rv := count ;
    end procedure ;

    procedure concatenate_list(variable parts : string_list ; variable rv : inout line) is
        variable start  : positive  := 1 ;
        variable stop   : positive  := 1 ;
        variable l      : line      := null ;
        variable len    : natural   := 0 ;
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

end package body ;

-- Package: fmt
-- Description
--  A string formatting package that is based on the Python format specifier.
--  See this website for some information:
--
--    https://realpython.com/python-formatted-output/#the-format_spec-component
--
--  Currently supported is:
--
--    :[fill][align][sign][width][.precision][class]
--
--  fill: Any character
--    The character to fill any extra space when the string does not fit the
--    requested width.
--
--  align: '<', '>', '^', '='
--    <     Left alignment
--    >     Right alignment
--    ^     Center alignment
--    =     Sign alignment (d, e, f, u classes only)
--
--  sign: '+'
--    Ensures the sign is always printed for a number.
--
--  width: A number
--    The minimum number of characters to write.
--
--  .precision: A point then a number.
--    For the (e, f) classes, prints the number of points to the right of the decimal.
--    For the t class, determines which timebase to utilize for conversion.
--      Precision   Time Unit
--      .0          1 second
--      .3          1 millisecond
--      .6          1 microsecond
--      .9          1 nanosecond
--      .12         1 picosecond
--      .15         1 femtosecond
--
--  class: 'b', 'c', 'd', 'e', 'f', 'o', 's', 't', 'u', 'x'
--      Character       Class
--      b               Binary
--      c               Character
--      d               Signed integer
--      e               Floating point (exp notation - i.e. 3.14159e+00)
--      f               Floating point (fixed notation - i.e. 3.14159)
--      o               Octal
--      s               String
--      t               Time value
--      u               Unsigned integer
--      x               Hexadecimal
--    Note: Both lowercase and uppercase class values are accepetd.
use std.textio.line ;
use std.textio.side ;

use std.textio.read ;
use std.textio.bread ;
use std.textio.hread ;
use std.textio.oread ;

use std.textio.write ;
use std.textio.bwrite ;
use std.textio.hwrite ;
use std.textio.owrite ;

use work.string_list.all ;

package fmt is
    ---------------------------------------------------------------------------
    -- VHDL-2008 Generic Function
    ---------------------------------------------------------------------------
    ---- TODO: Generic f() function which utilizes the type'image to get the string and just pass to fstr()?
    ---- Useful for custom enumerated types?
    --function fstring
    --    generic(type t; function to_string(x : t) return string is <>)
    --    parameter(value : t ; sfmt : string := "s")
    --    return string ;
    --
    --function fimage
    --    generic(type t)
    --    parameter(value : t ; sfmt : string := "s")
    --    return string;

    -- Format string building function using a string_list
    procedure f(sfmt : string ; variable args : inout string_list ; variable l : inout line) ;
    alias fmt is f[string, string_list, line] ;

    -- Format string building function using up to 16 arguments
    function f(sfmt : string ; a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 : in string := "") return string ;
    alias fmt is f[string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string return string] ;

    -- Single argument formatting
    function f(sfmt : string ; value : bit) return string ;
    function f(sfmt : string ; value : bit_vector) return string ;
    function f(sfmt : string ; value : boolean) return string ;
    function f(sfmt : string ; value : character) return string ;
    function f(sfmt : string ; value : integer) return string ;
    function f(sfmt : string ; value : real) return string ;
    function f(sfmt : string ; value : time) return string ;

    -- Functions to format standard types
    -- NOTE: Aliases added for ambiguous types
    function f(value : bit ; sfmt : string := "b") return string ;
    alias fbit is f[bit, string return string] ;

    function f(value : bit_vector ; sfmt : string := "b") return string ;
    alias fbv is f[bit_vector, string return string] ;

    function f(value : boolean ; sfmt : string := "s") return string ;

    function f(value : character ; sfmt : string := "c") return string ;
    alias fchar is f[character, string return string] ;

    function f(value : integer ; sfmt : string := "d") return string ;
    function f(value : real ; sfmt : string := "f") return string ;

    function f(value : string ; sfmt : string := "s") return string ;
    alias fstr is f[string, string return string] ;

    function f(value : time ; sfmt : string := ".9t") return string ;

end package ;

package body fmt is

    -- Internal private types
    -- Format Alignment
    --  LEFT        'example      '
    --  RIGHT       '      example'
    --  CENTERED    '   example   '
    --  SIGN_EDGE   '+           3'
    type align_t is (LEFT, RIGHT, CENTERED, SIGN_EDGE) ;

    -- Format Class
    --  b   Binary
    --  c   Character
    --  d   Signed integer
    --  e   Floating point (exp notation)
    --  f   Floating point (fixed notation)
    --  o   Octal
    --  s   String
    --  t   Time value
    --  u   Unsigned integer
    --  x   Hexadecimal
    type class_t is (BINARY, CHAR, INT, FLOAT_EXP, FLOAT_FIXED, OCTAL, STR, TIMEVAL, UINT, HEX) ;

    function f(sfmt : string ; value : align_t) return string ;
    function f(sfmt : string ; value : class_t) return string ;
    function f(value : align_t ; sfmt : string := "s") return string ;
    function f(value : class_t ; sfmt : string := "s") return string ;

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
        class       =>  STR
    ) ;

    -- Private Helper functions
    function parse(sfmt : string ; default_class : class_t := STR) return fmt_spec_t ;

    -- Collapse align_t to be side (LEFT, RIGHT)
    function to_side(value : align_t) return side ;

    -- Helper functions for line manipulation for custom f-functions
    procedure fill(variable l : inout line ; variable fmt_spec : fmt_spec_t ; variable fillcount : inout natural) ;
    procedure shift(variable l : inout line ; count : in natural) ;

    ---------------------------------------------------------------------------
    -- VHDL-2008 Generic Function
    ---------------------------------------------------------------------------
    --function f
    --    generic(type t; function to_string(x : t) return string is <>)
    --    parameter(value : t ; sfmt : string := "s")
    --    return string
    --is
    --begin
    --    return fstr(to_string(value), sfmt) ;
    --end function ;

    --function f
    --    generic(type t)
    --    parameter(value : t ; sfmt : string := "s")
    --    return string
    --is
    --begin
    --    return fstr(t'image(value), sfmt) ;
    --end function ;

    function parse(sfmt : string ; default_class : class_t := STR) return fmt_spec_t is
        type fsm_t is (START, FILL, ALIGN, SIGN, WIDTH, DOT, PRECISION, CLASS, EXTRA) ;
        alias fn                    : string(1 to sfmt'length) is sfmt ;
        variable l                  : line          := null ;
        variable fsm                : fsm_t         := START ;
        variable rv                 : fmt_spec_t    := DEFAULT_FMT_SPEC ;
        variable idx                : positive      := 1 ;
        variable numstart           : natural       := 0 ;
        variable numstop            : natural       := 0 ;
        variable precision_present  : boolean       := false ;
    begin
        assert fn'length > 0
            report "Format string must not be empty"
                severity warning ;
        rv.class := default_class ;
        while idx <= fn'length loop
            case fsm is
                when START =>
                    if fn'length = 1 then
                        -- Only a single character
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

                            when 'b'|'B'|'c'|'C'|'d'|'D'|'e'|'E'|'f'|'F'|'o'|'O'|'s'|'S'|'t'|'T'|'u'|'U'|'x'|'X' =>
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
                                    when '<'|'>'|'^'|'='|'0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                                        -- Alignment character is second, so fill character is first
                                        fsm := FILL ;

                                    when others =>
                                        report fmt("Invalid format specifier: {}", fstr(fn))
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
                                l := new string'(fn(numstart to numstop)) ;
                                read(l, rv.width) ;
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
                                l := new string'(fn(numstart to numstop)) ;
                                read(l, rv.precision) ;
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
                        when 'e'|'E' =>
                            -- Normalized d[.precision]e[+-]dd notation
                            rv.class := FLOAT_EXP ;
                            if precision_present = false then
                                -- Precision isn't mentioned, so default to 6
                                rv.precision := 6 ;
                            end if ;
                        when 'f'|'F' =>
                            if precision_present = true then
                                if rv.precision = 0 then
                                    -- Precision was specified, so change the class to int to cut off
                                    -- any decimal representation
                                    rv.class := INT ;
                                else
                                    rv.class := FLOAT_FIXED ;
                                end if ;
                            else
                                -- Precision isn't present, so default the precision to 6 places
                                rv.precision := 6 ;
                                rv.class := FLOAT_FIXED ;
                            end if ;
                        when 'o'|'O' =>
                            rv.class := OCTAL ;
                        when 's'|'S' =>
                            rv.class := STR ;
                        when 't'|'T' =>
                            rv.class := TIMEVAL ;
                        when 'u'|'U' =>
                            rv.class := UINT ;
                        when 'x'|'X' =>
                            rv.class := HEX ;
                        when others =>
                            rv.class := BINARY ;
                            report fmt("Unknown class: {} is not [bcdofsux] - defaulting to BINARY", f(fn(idx)))
                                severity warning ;
                    end case ;
                    idx := idx + 1 ;
                    fsm := EXTRA ;

                when EXTRA =>
                    report fmt("Extra characters in format specifier ignored : {}",  fstr(fn(idx to fn'length)))
                        severity warning ;
                    exit ;

            end case ;
        end loop ;

        -- Parse the last bit of data
        case fsm is
            when WIDTH =>
                l := new string'(sfmt(numstart to numstop)) ;
                read(l, rv.width) ;
            when PRECISION =>
                l := new string'(sfmt(numstart to numstop)) ;
                read(l, rv.precision) ;
            when others =>
                null ;
        end case ;
        return rv ;
    end function ;

    procedure shift(variable l : inout line ; count : in natural) is
        variable newl : line        := new string'(l.all) ;
        variable dest : positive    := count + 1 ;
    begin
        if count > 0 then
            for idx in l'range loop
                newl(dest) := l(idx) ;
                dest := dest + 1 ;
                if dest = l'length + 1 then
                    dest := 1 ;
                end if ;
            end loop ;
            l := newl ;
        end if ;
    end procedure ;

    function to_side(value : align_t) return side is
    begin
        case value is
            when RIGHT|SIGN_EDGE =>
                return right ;
            when others =>
                return left ;
        end case ;
    end function ;

    procedure fill(variable l : inout line ; variable fmt_spec : fmt_spec_t ; variable fillcount : inout natural) is
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

    function f(value : string ; sfmt : string := "s") return string is
        alias s             : string(1 to value'length) is value ;
        variable fmt_spec   : fmt_spec_t := parse(sfmt, STR) ;
        variable l          : line ;
        variable fillcount  : integer := fmt_spec.width - value'length ;
        constant static_fill : string(1 to fillcount) := (others => fmt_spec.fill) ;
    begin
        if (fmt_spec.precision > 0) and (value'length > fmt_spec.precision) then
            -- Limiting the string size based on precision
            return s(1 to fmt_spec.precision) ;
        else
            -- The string might have spaces included, so lets create
            fillcount := fmt_spec.width - value'length ;
            case fmt_spec.align is
                when LEFT|CENTERED =>
                    write(l, s & static_fill, to_side(fmt_spec.align)) ;
                when others =>
                    write(l, static_fill & s, to_side(fmt_spec.align)) ;
            end case ;
        end if ;
        if fillcount > 0 and fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        return l.all ;
    end function ;

    function f(value : align_t ; sfmt : string := "s") return string is
        constant s : string := align_t'image(value) ;
    begin
        return fstr(s, sfmt) ;
    end function ;

    function f(value : class_t ; sfmt : string := "s") return string is
        constant s : string := class_t'image(value) ;
    begin
        return fstr(s, sfmt) ;
    end function ;

    function f(value : bit ; sfmt : string := "b") return string is
        variable fmt_spec   : fmt_spec_t := parse(sfmt, BINARY) ;
        variable l          : line ;
        variable fillcount  : natural ;
    begin
        write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        fill(l, fmt_spec, fillcount) ;
        if fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        return l.all ;
    end function ;

    function f(value : bit_vector ; sfmt : string := "b") return string is
        variable fmt_spec   : fmt_spec_t := parse(sfmt, BINARY) ;
        variable l          : line ;
        variable fillcount  : natural ;
    begin
        case fmt_spec.class is
            when BINARY =>
                bwrite(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
            when OCTAL =>
                owrite(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
            when HEX =>
                hwrite(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
            when others =>
                report f("Unsupported class for bit_vector ({}), using binary: {}", fmt_spec.class)
                    severity warning ;
                bwrite(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        end case ;
        fill(l, fmt_spec, fillcount) ;
        if fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        return l.all ;
    end function ;

    function f(value : boolean ; sfmt : string := "s") return string is
        variable fmt_spec   : fmt_spec_t := parse(sfmt, BINARY) ;
        variable l          : line ;
        variable bit_arg    : bit := '0' ;
        variable fillcount  : natural ;
    begin
        case fmt_spec.class is
            when STR =>
                write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;

            when BINARY =>
                if value = true then
                    bit_arg := '1' ;
                end if ;
                l := new string'(f(bit_arg, sfmt)) ;
                return l.all ;

            when others =>
                report fstr("Unsupported class for boolean - {}, using STR", f(fmt_spec.class))
                    severity warning ;
                write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        end case ;
        fill(l, fmt_spec, fillcount) ;
        if fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        return l.all ;
    end function ;

    function f(value : character ; sfmt : string := "c") return string is
        variable fmt_spec   : fmt_spec_t := parse(sfmt, CHAR) ;
        variable l          : line ;
        variable fillcount  : natural ;
    begin
        write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        fill(l, fmt_spec, fillcount) ;
        if fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        return l.all ;
    end function ;

    function f(value : time ; sfmt : string := ".9t" ) return string is
        variable fmt_spec   : fmt_spec_t := parse(sfmt, TIMEVAL) ;
        variable l          : line ;
        variable unit       : time := 1 ns ;
        variable fillcount  : natural ;
    begin
        case fmt_spec.precision is
            when 0  => unit := 1 sec ;
            when 3  => unit := 1 ms ;
            when 6  => unit := 1 us ;
            when 9  => unit := 1 ns ;
            when 12 => unit := 1 ps ;
            when 15 => unit := 1 fs ;
            when others =>
                report fmt("Time precision unknown: {}, using default", f(fmt_spec.precision))
                    severity warning ;
        end case ;
        write(l, value, to_side(fmt_spec.align), fmt_spec.width, unit) ;
        fill(l, fmt_spec, fillcount) ;
        if fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        return l.all ;
    end function ;

    procedure add_sign(variable l : inout line ; s : character ; fmt_fill : character ) is
        variable idx : natural := 1 ;
    begin
        while l(idx) = fmt_fill loop
            idx := idx + 1 ;
        end loop ;
        l(idx-1) := s ;
    end procedure ;

    function f(value : integer ; sfmt : string := "d") return string is
        variable fmt_spec   : fmt_spec_t    := parse(sfmt, INT) ;
        variable l          : line          := null ;
        variable temp       : line          := null ;
        variable fillcount  : natural       := 0 ;
        variable sign       : character ;
    begin
        write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        fill(l, fmt_spec, fillcount) ;
        if fmt_spec.align = CENTERED then
            shift(l, fillcount/2) ;
        end if ;
        if fmt_spec.sign = true then
            if fmt_spec.width = 0 then
                write(temp, l.all, right, l'length+1) ;
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
        --        return f(ieee.std_logic_1164.std_logic_vector(ieee.numeric_std.to_unsigned(value, fmt_spec.width)), sfmt) ;
        --    when OCTAL =>
        --        return f(ieee.std_logic_1164.std_logic_vector(ieee.numeric_std.to_unsigned(value, fmt_spec.width*3)), sfmt) ;
        --    when HEX =>
        --        return f(ieee.std_logic_1164.std_logic_vector(ieee.numeric_std.to_unsigned(value, fmt_spec.width*4)), sfmt) ;
        --    when INT|UINT =>
        --        write(l, value, to_side(fmt_spec.align), fmt_spec.width) ;
        --    when others =>
        --        report "Unsure what to do here"
        --            severity warning ;
        --end case ;
        return l.all ;
    end function ;

    function f(value : real ; sfmt : string := "f") return string is
        variable fmt_spec   : fmt_spec_t    := parse(sfmt, FLOAT_FIXED) ;
        variable l          : line          := null ;
        variable exp        : line          := null ;
        variable precision  : line          := null ;
        variable temp       : line          := null ;
        variable tempreal   : real          := 0.0 ;
        variable fillcount  : natural       := 0 ;
        variable sign       : character ;
        variable prec       : real ;
        variable expstart   : positive      := 1 ;
    begin
        if fmt_spec.class = INT then
            -- Cast to an integer
            return f(integer(value), sfmt) ;
        elsif fmt_spec.class = FLOAT_EXP then
            -- Limit the precision first so things round correctly
            if fmt_spec.align = SIGN_EDGE then
                write(exp, abs(value), left, fmt_spec.width, 0) ;
            else
                write(exp, value, left, fmt_spec.width, 0) ;
            end if ;
            -- Find expstart
            while expstart < exp'length and exp(expstart) /= 'e' and exp(expstart) /= 'E' loop
                expstart := expstart + 1 ;
            end loop ;
            if expstart = exp'length then
                expstart := exp'length + 1 ;
            end if ;

            -- Precision is just for digits, not for sign
            prec := abs(value) ;

            -- Make sure we're going to get the right decimal points
            while prec > 10.0 loop
                prec := prec / 10.0 ;
            end loop ;
            -- Make sure we are e+00
            if abs(prec) < 0.1 then
                prec := 1.0 + prec ;
            end if ;
            write(precision, prec, left, 0, fmt_spec.precision);
            -- ... now concatenate the info from exp and precision into the full string
            if fmt_spec.precision > 0 then
                if value < 0.0 and fmt_spec.align /= SIGN_EDGE then
                    l := new string'(exp(1 to 3) & precision(3 to 3+fmt_spec.precision-1) & exp(expstart to exp'high)) ;
                else
                    l := new string'(exp(1 to 2) & precision(3 to 3+fmt_spec.precision-1) & exp(expstart to exp'high)) ;
                end if ;
            else
                if value < 0.0 and fmt_spec.align /= SIGN_EDGE then
                    l := new string'(exp(1 to 2) & exp(expstart to exp'high)) ;
                else
                    l := new string'(exp(1 to 1) & exp(expstart to exp'high)) ;
                end if ;
            end if ;
            -- Justify the string that is left justified
            write(temp, l.all, to_side(fmt_spec.align), fmt_spec.width) ;
            l := temp ;
            temp := null ;
        elsif fmt_spec.class = FLOAT_FIXED then
            if fmt_spec.align = SIGN_EDGE then
                -- Don't write the sign since SIGN_EDGE formatting down lower takes care of it
                write(l, abs(value), to_side(fmt_spec.align), fmt_spec.width, fmt_spec.precision) ;
            else
                write(l, value, to_side(fmt_spec.align), fmt_spec.width, fmt_spec.precision) ;
            end if ;
        end if ;

        if value < 0.0 then
            sign := '-' ;
        else
            sign := '+' ;
        end if ;

        fill(l, fmt_spec, fillcount) ;

        case fmt_spec.align is

            when SIGN_EDGE =>
                if fmt_spec.sign = false then
                    report "Format alignment set to SIGN_EDGE without SIGN - assuming SIGN"
                        severity warning ;
                end if ;
                if fillcount = 0 then
                    write(temp, l.all, right, l'length+1) ;
                    l := temp ;
                end if ;
                l(1) := sign ;

            when LEFT|CENTERED =>
                if not (value < 0.0) and fmt_spec.sign = true then
                    if fillcount = 0 then
                        -- Full number in line, but we need room for the sign, so extend by 1
                        write(temp, l.all, left, l'length+1) ;
                        l := temp ;
                    end if ;
                    -- Shift the line to the right by 1
                    shift(l, 1) ;

                    -- Add the sign
                    l(1) := sign ;
                end if ;

                if fmt_spec.align = CENTERED then
                    -- Alignment just needs to be shifted
                    shift(l, fillcount/2) ;
                end if ;

            when RIGHT =>
                if fmt_spec.sign = true then
                    if fillcount = 0 then
                        -- Full number in line, but we need room for the sign, so extend by 1
                        write(temp, l.all, right, l'length+1) ;
                        l := temp ;
                    end if ;
                    -- Add the sign
                    if not (value < 0.0) then
                        add_sign(l, sign, fmt_spec.fill) ;
                    end if ;
                end if ;

            when others =>
                report "Got into a strange place"
                    severity warning ;
        end case ;

        return l.all ;
    end function ;

    procedure reformat(variable l : inout line ; sfmt : in string) is
        type bv_ptr is access bit_vector ;
        constant fmt_spec       : fmt_spec_t := parse(sfmt) ;
        variable good           : boolean ;
        variable bit_arg        : bit ;
        variable bv_arg_ptr     : bv_ptr ;
        variable boolean_arg    : boolean ;
        variable integer_arg    : integer ;
        variable real_arg       : real ;
        variable time_arg       : time ;
        variable strl           : line := l ;
    begin
        case fmt_spec.class is
            when STR =>
                -- Just strings that need to be put into the actual format
                l := new string'(fstr(strl.all, sfmt)) ;

            when BINARY =>
                -- boolean, bit, bit_vector, or integer could be the source for this
                -- Try boolean: true|false
                read(strl, boolean_arg, good) ;
                if good = true then
                    if sfmt'length > 0 then
                        l := new string'(f(boolean_arg, sfmt)) ;
                    else
                        l := strl ;
                    end if ;
                end if;

                -- Try bit_vector
                if good = false then
                    bv_arg_ptr := new bit_vector(0 to strl'length-1) ;
                    read(strl, bv_arg_ptr.all, good) ;
                    if good = true then
                        if sfmt'length > 0 then
                            l := new string'(f(bv_arg_ptr.all, sfmt)) ;
                        else
                            l := strl ;
                        end if ;
                    end if ;
                end if ;

                -- Try integer: note integer might be read, but actually bit_vector, so ambiguous should be noted
                if good = false then
                    read(strl, integer_arg, good) ;
                    if good = true then
                        if sfmt'length > 0 then
                            l := new string'(f(integer_arg, sfmt)) ;
                        else
                            l := strl ;
                        end if ;
                    end if ;
                end if ;

                -- Never parsed it so warn
                if good = false then
                    report fmt("Could not parse '{}' as BINARY", strl.all)
                    severity warning ;
                end if ;

            when OCTAL|HEX =>
                -- Try bit_vector
                bv_arg_ptr := new bit_vector(0 to strl'length-1) ;
                read(strl, bv_arg_ptr.all, good) ;
                if good = true then
                    if sfmt'length > 0 then
                        l := new string'(f(bv_arg_ptr.all, sfmt)) ;
                    else
                        l := strl ;
                    end if ;
                end if ;

                if good = false then
                    -- Try integer
                    read(strl, integer_arg, good) ;
                    if good = true then
                        if sfmt'length > 0 then
                            l := new string'(f(integer_arg, sfmt)) ;
                        else
                            l := strl ;
                        end if ;
                    end if ;
                end if ;

                -- Never parsed it so warn
                if good = false then
                    report fmt("Could not parse '{}' as OCTAL or HEX", strl.all)
                    severity warning ;
                end if ;

            when CHAR =>
                if sfmt'length > 0 then
                    l := new string'(f(strl(strl'low), sfmt)) ;
                else
                    l := strl ;
                end if ;

            when INT|UINT =>
                -- Try integer
                read(strl, integer_arg, good) ;
                if good = false then
                    report fmt("Invalid integer argument: {}", strl.all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    l := new string'(f(integer_arg, sfmt)) ;
                else
                    l := strl ;
                end if ;

                -- Try bit_vector

            when FLOAT_EXP|FLOAT_FIXED =>
                read(strl, real_arg, good) ;
                if good = false then
                    report fmt("Invalid real argument: {}", strl.all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    l := new string'(f(real_arg, sfmt)) ;
                else
                    l := strl ;
                end if ;

            when TIMEVAL =>
                read(strl, time_arg, good) ;
                if good = false then
                    report fmt("Invalid time argument: {}", strl.all)
                        severity warning ;
                end if ;
                if sfmt'length > 0 then
                    l := new string'(f(time_arg, sfmt)) ;
                else
                    l := strl ;
                end if ;

            when others =>
                report "Unknown type to reformat"
                    severity warning ;
        end case ;
    end procedure ;

    procedure create_parts(fn : string ; variable parts : inout string_list ; variable args : inout string_list) is
        type fsm_t is (COPY_STRING, LBRACE, RBRACE, READ_ARGNUM, READ_FMT) ;
        variable fsm            : fsm_t := COPY_STRING ;
        variable start          : positive ;
        variable stop           : positive ;
        variable argnum         : integer := 0 ;
        variable numstart       : positive ;
        variable numstop        : positive ;
        variable argnum_used    : boolean := false ;
        variable argnum_limited : natural := 0 ;
        variable len            : natural ;
        variable l              : line ;
        variable fmt_start      : positive ;
        variable fmt_stop       : positive ;
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

                            -- Check the length
                            length(args, len) ;
                            assert argnum <= len
                                report fmt("Too many arguments given the list: {} > {}", f(argnum), f(len))
                                    severity warning ;
                            if argnum_used = true then
                                report fmt("Cannot mix argnum usage in format string: {} @ {}", fn, f(i)) ;
                            end if ;
                            if argnum >= len then
                                argnum_limited := argnum_limited + 1 ;
                                argnum := len - 1 ;
                            end if ;

                            -- Append the argument
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

                        when ':' =>
                            -- No argument number here, just format specifier ...
                            -- ... but don't increment the argnum yet
                            length(args, len) ;

                            -- Get ready to parse the format specifier
                            fmt_start := i + 1 ;
                            fmt_stop := i + 1 ;
                            fsm := READ_FMT ;

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
                            report fmt("Parsing error, RBRACE without corresponding LBRACE or RBRACE at {}: {}", f(i-1), fstr(fn))
                                severity warning ;
                    end case ;

                when READ_ARGNUM =>
                    case fn(i) is
                        when '}' =>
                            l := new string'(fn(numstart to numstop)) ;
                            read(l, argnum) ;

                            -- Check the length
                            length(args, len) ;

                            assert argnum < len
                                report fmt("Invalid argnum ({}) - total arguments: {}", f(argnum), f(len))
                                severity warning ;

                            if argnum >= len then
                                argnum_limited := argnum_limited + 1 ;
                                argnum := len - 1 ;
                            end if ;

                            -- Append the argument from the args string_list
                            get(args, argnum, l) ;
                            append(parts, l.all) ;

                            -- Start the next piece
                            fsm := COPY_STRING ;
                            start := i + 1 ;
                            stop := i ;

                        when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                            numstop := i ;

                        when ':' =>
                            -- Read the argnum, but go off to read and reformat the argument
                            l := new string'(fn(numstart to numstop)) ;
                            read(l, argnum) ;

                            -- Check the length
                            length(args, len) ;

                            assert argnum < len
                                report fmt("Invalid argnum ({}) - total arguments: {}", f(argnum), f(len))
                                severity warning ;

                            if argnum >= len then
                                argnum_limited := argnum_limited + 1 ;
                                argnum := len - 1 ;
                            end if ;

                            fsm := READ_FMT ;
                            fmt_start := i + 1 ;
                            fmt_stop := i + 1 ;

                        when others =>
                            report fmt("Invalid argument specifier ({}) at position {}", f(fn(i)), f(i))
                                severity warning ;

                    end case ;

                when READ_FMT =>
                    case fn(i) is
                        when '}' =>
                            -- End of the format so check argument numbers
                            length(args, len) ;

                            assert argnum <= len
                                report fmt("Too many arguments given the list: {} > {}", f(argnum), f(len))
                                    severity warning ;

                            -- Keep track of the number of times we limit arguments
                            if argnum >= len then
                                argnum_limited := argnum_limited + 1 ;
                                argnum := len - 1 ;
                            end if ;

                            -- Initial formatted argument now in l
                            get(args, argnum, l) ;

                            -- Reformat
                            reformat(l, fn(fmt_start to fmt_stop)) ;

                            -- Add the reformatted line to the argnums
                            append(parts, l.all) ;

                            -- Increment the argnum if we aren't explicitly noting the arguments
                            if argnum_used = false then
                                argnum := argnum + 1 ;
                            end if ;

                            -- Start the next piece
                            fsm := COPY_STRING ;
                            start := i + 1 ;
                            stop := i ;

                        when others =>
                            -- Haven't closed the brace yet, so just keep going
                            fmt_stop := i ;

                    end case ;
            end case ;
        end loop ;

        if fn(start to stop)'length > 0 then
            -- Add the final bit
            append(parts, fn(start to stop) ) ;
        end if ;

        -- Check if we hit an argnum limit
        if argnum_limited > 0 then
            length(args, len) ;
            report f("More formats than arguments: {} extra", argnum_limited)
                severity warning ;
        end if ;

        if argnum_used = false then
            length(args, len) ;
            if argnum /= len then
                report fmt("Extra arguments passed into format expression - passed {}, but used {}", f(len), f(argnum))
                    severity warning ;
            end if ;
        end if ;
    end procedure ;

    procedure f(sfmt : string ; variable args : inout string_list ; variable l : inout line) is
        alias fn        : string(1 to sfmt'length) is sfmt ;
        variable parts  : string_list ;
    begin
        -- Zero length format string short circuit
        if fn'length = 0 then
            l := new string'("") ;
            return ;
        end if ;

        -- Create parts to concatenate removing the formatting
        create_parts(fn, parts, args) ;

        -- Return the concatenated parts
        concatenate_list(parts, l) ;
    end procedure ;

    function f(sfmt : string ; a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 : in string := "") return string is
        -- Normalize the format string
        alias fn        : string(1 to sfmt'length) is sfmt ;

        -- Arguments and parts of the strings to put together
        variable args   : string_list ;
        variable parts  : string_list ;

        -- Concatenation line
        variable l      : line  := null ;

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
    begin
        -- Zero length format string short circuit
        if fn'length = 0 then
            return "" ;
        end if ;

        -- Set the arguments for the formatter
        add_args ;

        -- Call into the one taking the string_list for args
        f(sfmt, args, l) ;

        -- Return the string
        return l.all ;
    end function ;

    -- Single argument formatters
    function f(sfmt : string ; value : align_t) return string is
    begin
        return fmt(sfmt, f(value)) ;
    end function ;

    function f(sfmt : string ; value : bit) return string is
    begin
        return fmt(sfmt, f(value)) ;
    end function ;

    function f(sfmt : string ; value : bit_vector) return string is
    begin
        return fmt(sfmt, f(value)) ;
    end function ;

    function f(sfmt : string ; value : boolean) return string is
    begin
        return fmt(sfmt, f(value)) ;
    end function ;

    function f(sfmt : string ; value : character) return string is
    begin
        return fmt(sfmt, f(value)) ;
    end function ;

    function f(sfmt : string ; value : class_t) return string is
    begin
        return fmt(sfmt, f(value)) ;
    end function ;

    function f(sfmt : string ; value : integer) return string is
    begin
        return fmt(sfmt, f(value)) ;
    end function ;

    function f(sfmt : string ; value : real) return string is
    begin
        return fmt(sfmt, f(value)) ;
    end function ;

    function f(sfmt : string ; value : time) return string is
    begin
        return fmt(sfmt, f(value)) ;
    end function ;

end package body ;

