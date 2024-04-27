use std.textio.write ;
use std.textio.output ;

use work.fmt.f ;
use work.fmt.p ;
use work.fmt.fbit ;
use work.fmt.fbv ;
use work.fmt.fchar ;
use work.fmt.fmt ;
use work.fmt.fstr ;

use work.colors.ansi ;

library ieee ;
use ieee.math_real.MATH_PI ;
use ieee.fixed_pkg.sfixed ;
use ieee.fixed_pkg.to_sfixed ;

entity fmt_examples is end entity ;

architecture arch of fmt_examples is

begin

    process
        variable sfval : sfixed(5 downto -10) := to_sfixed(MATH_PI, 5, -10) ;
    begin
        -- Easy string substitution
        p(fmt("{} {}", "hello", "world")) ;

        -- Argument renumbering, if you're into that
        p(fmt("{1} {0}", "world", "hello")) ;

        -- Types supported
        p(f  ("bit                : '{}'", bit'('1'))) ;
        p(f  ("bit_vector         : '{}'", bit_vector'("110010001110"))) ;
        p(f  ("boolean            : '{}'", false)) ;
        p(f  ("character          : '{}'", character'('c'))) ;
        p(f  ("real               : '{}'", MATH_PI)) ;
        p(fmt("string             : '{}'", "the quick brown fox jumps over the lazy dog")) ;
        p(f  (string'("time               : '{}'"), 1.23 ns)) ;

        -- Inserting braces into your string
        p(fmt("braces             : '{{{}}}'", "included")) ;

        -- Formatting supported
        p(fmt("justified          : '{}'", fstr("left", "<20s"))) ;
        p(fmt("justified          : '{}'", fstr("centered", "^20s"))) ;
        p(fmt("justified          : '{}'", fstr("right", ">20s"))) ;
        p(fmt("filled             : '{}'", fstr("left", "~<20s"))) ;
        p(fmt("filled             : '{}'", fstr("centered", "~^20s"))) ;
        p(fmt("filled             : '{}'", fstr("right", "~>20s"))) ;

        -- Time resolutions
        -- When the precision is set to a number, it's the exponent for the unit, so ...
        --  15      10^-15  fs
        --  12      10^-12  ps
        --   9      10^-9   ns
        --   6      10^-6   us
        --   3      10^-3   ms
        --   0      10^0    seconds
        p(fmt("1 us in fs         : '{}'", f(1 us, "0.15f"))) ;
        p(fmt("1 us in ps         : '{}'", f(1 us, "0.12f"))) ;
        p(fmt("1 us in ns         : '{}'", f(1 us, "0.9f"))) ;
        p(fmt("1 us in us         : '{}'", f(1 us, "0.6f"))) ;
        p(fmt("1 us in ms         : '{}'", f(1 us, "0.3f"))) ;
        p(fmt("1 us in seconds    : '{}'", f(1 us, "0.0f"))) ;

        -- Real Numbers
        p(fmt("real exp           : '{}'", f(MATH_PI, "e"))) ;
        p(fmt("real fixed         : '{}'", f(MATH_PI, "f"))) ;
        p(fmt("real exp sign      : '{}'", f(MATH_PI, "+0.6e"))) ;
        p(fmt("real fixed sign    : '{}'", f(MATH_PI, "+0.6f"))) ;
        p(fmt("real width exp <   : '{}'", f(MATH_PI, "<+20.6e"))) ;
        p(fmt("real width exp ^   : '{}'", f(MATH_PI, "^+20.6e"))) ;
        p(fmt("real width exp >   : '{}'", f(MATH_PI, ">+20.6e"))) ;
        p(fmt("real width exp =   : '{}'", f(MATH_PI, "=+20.6e"))) ;
        p(fmt("real width fixed < : '{}'", f(-MATH_PI, "<+20.6f"))) ;
        p(fmt("real width fixed ^ : '{}'", f(-MATH_PI, "^+20.6f"))) ;
        p(fmt("real width fixed > : '{}'", f(-MATH_PI, ">+20.6f"))) ;
        p(fmt("real width fixed = : '{}'", f(-MATH_PI, "=+20.6f"))) ;
        p(fmt("real wide > filled : '{}'", f(MATH_PI, "#>40.30f"))) ;

        -- Integer Number base conversion
        p(fmt("integer            : '{}'", f(13, "8d"))) ;
        p(fmt("integer zp         : '{}'", f(13, "08d"))) ;

        p(fmt("integer/binary     : '{}'", f(13, "8b"))) ;
        p(fmt("integer/binary zp  : '{}'", f(13, "08b"))) ;

        p(fmt("integer/octal      : '{}'", f(13, "8o"))) ;
        p(fmt("integer/octal zp   : '{}'", f(13, "08o"))) ;

        p(fmt("integer/hex        : '{}'", f(13, "8x"))) ;
        p(fmt("integer/hex zp     : '{}'", f(13, "08x"))) ;

        -- Bit Vector base conversion
        p(fmt("bv to int          : '{}'", fbv("10010001", "4d"))) ;
        p(fmt("bv to uint         : '{}'", fbv("10010001", "4u"))) ;
        p(fmt("bv to binary       : '{}'", fbv("10010001", ">16b"))) ;
        p(fmt("bv to binary zp    : '{}'", fbv("10010001", ">016b"))) ;
        p(fmt("bv to octal        : '{}'", fbv("10010001", ">4o"))) ;
        p(fmt("bv to octal zp     : '{}'", fbv("10010001", ">04o"))) ;
        p(fmt("bv to hex          : '{}'", fbv("10010001", ">4x"))) ;
        p(fmt("bv to hex zp       : '{}'", fbv("10010001", ">04x"))) ;

        -- Boolean conversions
        p(fmt("boolean to binary  : '{}'", f(true, ">04b"))) ;

        -- Strings
        p(fmt("limited to 4       : '{}'", fstr("limited", "0.4s"))) ;
        p(fmt("limited to 20      : '{}'", fstr("limited", ">10.20s"))) ;
        p(fmt("fill keep spaces < : '{}'" & lF, fstr("    spaces    ", "~<20s"))) ;
        p(fmt("fill keep spaces > : '{}'" & lF, fstr("    spaces    ", "~>20s"))) ;
        p(fmt("fill keep spaces ^ : '{}'" & lF, fstr("    spaces    ", "~^20s"))) ;

        -- Inline reformatting
        p(fmt("reformatted string : {{{:>8s}}}", "value")) ;
        p(fmt("log message        : '{:>10s}@{:>20.9t}: {:~40s}!'", fstr("uut"), f(10 us), fstr("A silly message to log"))) ;

        -- Ambiguous/Problematic strings
        p(fmt("integer/binary amb : '{:>16b}'", f(1100))) ;
        p(fmt("integer/binary amb : '{}'", f(1100, ">16b"))) ;
        p(fmt("integer/octal amb  : '{:>16o}'", f(1100))) ;
        p(fmt("integer/octal amb  : '{}'", f(1100, ">16o"))) ;
        p(fmt("integer/hex amb    : '{:>16x}'", f(1100))) ;
        p(fmt("integer/hex amb    : '{}'", f(1100, ">16x"))) ;

        -- ANSI Foreground Colors
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.BLACK,  "BLACK",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.RED,    "RED",    ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.GREEN,  "GREEN",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.YELLOW, "YELLOW", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.BLUE,   "BLUE",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.PURPLE, "PURPLE", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.CYAN,   "CYAN",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Bold Colors
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.bold.BLACK,  "BLACK",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.bold.RED,    "RED",    ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.bold.GREEN,  "GREEN",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.bold.YELLOW, "YELLOW", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.bold.BLUE,   "BLUE",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.bold.PURPLE, "PURPLE", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.bold.CYAN,   "CYAN",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.bold.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Underline Colors
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.underline.BLACK,  "BLACK",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.underline.RED,    "RED",    ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.underline.GREEN,  "GREEN",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.underline.YELLOW, "YELLOW", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.underline.BLUE,   "BLUE",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.underline.PURPLE, "PURPLE", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.underline.CYAN,   "CYAN",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.underline.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Background Colors
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.background.BLACK,  "BLACK",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.background.RED,    "RED",    ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.background.GREEN,  "GREEN",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.background.YELLOW, "YELLOW", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.background.BLUE,   "BLUE",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.background.PURPLE, "PURPLE", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.background.CYAN,   "CYAN",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.background.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Intense Colors
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intense.BLACK,  "BLACK",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intense.RED,    "RED",    ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intense.GREEN,  "GREEN",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intense.YELLOW, "YELLOW", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intense.BLUE,   "BLUE",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intense.PURPLE, "PURPLE", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intense.CYAN,   "CYAN",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intense.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Bold Intense Colors
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.boldintense.BLACK,  "BLACK",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.boldintense.RED,    "RED",    ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.boldintense.GREEN,  "GREEN",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.boldintense.YELLOW, "YELLOW", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.boldintense.BLUE,   "BLUE",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.boldintense.PURPLE, "PURPLE", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.boldintense.CYAN,   "CYAN",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.boldintense.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Intense Background Colors
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intensebg.BLACK,  "BLACK",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intensebg.RED,    "RED",    ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intensebg.GREEN,  "GREEN",  ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intensebg.YELLOW, "YELLOW", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intensebg.BLUE,   "BLUE",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intensebg.PURPLE, "PURPLE", ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intensebg.CYAN,   "CYAN",   ansi.RESET)) ;
        p(fmt("colors             : '{}{:~^10s}{}'", ansi.intensebg.WHITE,  "WHITE",  ansi.RESET)) ;

        -- More colors
        p(fmt("colors             : '{}{:~^20s}{}'", ansi.underline.BLACK & ansi.background.white, "BLACK ON WHITE", ansi.RESET)) ;

        -- sfixed
        p(fmt("sfixed real        : '{}'", f(sfval))) ;
        p(fmt("sfixed binary      : '{}'", f(sfval, "b"))) ;
        p(fmt("sfixed octal       : '{}'", f(sfval, "o"))) ;
        p(fmt("sfixed hex         : '{}'", f(sfval, "x"))) ;
        p(fmt("sfixed int         : '{}'", f(sfval, "d"))) ;

        std.env.stop ;
    end process ;

end architecture ;

