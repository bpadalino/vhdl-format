use std.textio.write ;
use std.textio.output ;

use work.fmt.f ;
use work.fmt.fbit ;
use work.fmt.fbv ;
use work.fmt.fchar ;
use work.fmt.fmt ;
use work.fmt.fstr ;

use work.colors.ansi ;

library ieee ;
use ieee.math_real.MATH_PI ;

entity fmt_examples is end entity ;

architecture arch of fmt_examples is

begin

    process
    begin
        -- Easy string substitution
        write(output, fmt("{} {}" & LF, "hello", "world")) ;

        -- Argument renumbering, if you're into that
        write(output, fmt("{1} {0}" & LF, "world", "hello")) ;

        -- Types supported
        write(output, f  ("bit                : '{}'" & LF, bit'('1'))) ;
        write(output, f  ("bit_vector         : '{}'" & LF, bit_vector'("110010001110"))) ;
        write(output, f  ("boolean            : '{}'" & LF, false)) ;
        write(output, f  ("character          : '{}'" & LF, character'('c'))) ;
        write(output, f  ("real               : '{}'" & LF, MATH_PI)) ;
        write(output, fmt("string             : '{}'" & LF, "the quick brown fox jumps over the lazy dog")) ;
        write(output, f  ("time               : '{}'" & LF, 1.23 ns)) ;

        -- Inserting braces into your string
        write(output, fmt("braces             : '{{{}}}'" & LF, "included")) ;

        -- Formatting supported
        write(output, fmt("justified          : '{}'" & LF, fstr("left", "<20s"))) ;
        write(output, fmt("justified          : '{}'" & LF, fstr("centered", "^20s"))) ;
        write(output, fmt("justified          : '{}'" & LF, fstr("right", ">20s"))) ;
        write(output, fmt("filled             : '{}'" & LF, fstr("left", "~<20s"))) ;
        write(output, fmt("filled             : '{}'" & LF, fstr("centered", "~^20s"))) ;
        write(output, fmt("filled             : '{}'" & LF, fstr("right", "~>20s"))) ;

        -- Time resolutions
        -- When the precision is set to a number, it's the exponent for the unit, so ...
        --  15      10^-15  fs
        --  12      10^-12  ps
        --   9      10^-9   ns
        --   6      10^-6   us
        --   3      10^-3   ms
        --   0      10^0    seconds
        write(output, fmt("1 us in fs         : '{}'" & LF, f(1 us, "0.15f"))) ;
        write(output, fmt("1 us in ps         : '{}'" & LF, f(1 us, "0.12f"))) ;
        write(output, fmt("1 us in ns         : '{}'" & LF, f(1 us, "0.9f"))) ;
        write(output, fmt("1 us in us         : '{}'" & LF, f(1 us, "0.6f"))) ;
        write(output, fmt("1 us in ms         : '{}'" & LF, f(1 us, "0.3f"))) ;
        write(output, fmt("1 us in seconds    : '{}'" & LF, f(1 us, "0.0f"))) ;

        -- Real Numbers
        write(output, fmt("real exp           : '{}'" & LF, f(MATH_PI, "e"))) ;
        write(output, fmt("real fixed         : '{}'" & LF, f(MATH_PI, "f"))) ;
        write(output, fmt("real exp sign      : '{}'" & LF, f(MATH_PI, "+0.6e"))) ;
        write(output, fmt("real fixed sign    : '{}'" & LF, f(MATH_PI, "+0.6f"))) ;
        write(output, fmt("real width exp <   : '{}'" & LF, f(MATH_PI, "<+20.6e"))) ;
        write(output, fmt("real width exp ^   : '{}'" & LF, f(MATH_PI, "^+20.6e"))) ;
        write(output, fmt("real width exp >   : '{}'" & LF, f(MATH_PI, ">+20.6e"))) ;
        write(output, fmt("real width exp =   : '{}'" & LF, f(MATH_PI, "=+20.6e"))) ;
        write(output, fmt("real width fixed < : '{}'" & LF, f(-MATH_PI, "<+20.6f"))) ;
        write(output, fmt("real width fixed ^ : '{}'" & LF, f(-MATH_PI, "^+20.6f"))) ;
        write(output, fmt("real width fixed > : '{}'" & LF, f(-MATH_PI, ">+20.6f"))) ;
        write(output, fmt("real width fixed = : '{}'" & LF, f(-MATH_PI, "=+20.6f"))) ;
        write(output, fmt("real wide > filled : '{}'" & LF, f(MATH_PI, "#>40.30f"))) ;

        -- Integer Number base conversion
        write(output, fmt("integer            : '{}'" & LF, f(13, "8d"))) ;
        write(output, fmt("integer zp         : '{}'" & LF, f(13, "08d"))) ;

        write(output, fmt("integer/binary     : '{}'" & LF, f(13, "8b"))) ;
        write(output, fmt("integer/binary zp  : '{}'" & LF, f(13, "08b"))) ;

        write(output, fmt("integer/octal      : '{}'" & LF, f(13, "8o"))) ;
        write(output, fmt("integer/octal zp   : '{}'" & LF, f(13, "08o"))) ;

        write(output, fmt("integer/hex        : '{}'" & LF, f(13, "8x"))) ;
        write(output, fmt("integer/hex zp     : '{}'" & LF, f(13, "08x"))) ;

        -- Bit Vector base conversion
        write(output, fmt("bv to int          : '{}'" & LF, fbv("10010001", "4d"))) ;
        write(output, fmt("bv to uint         : '{}'" & LF, fbv("10010001", "4u"))) ;
        write(output, fmt("bv to binary       : '{}'" & LF, fbv("10010001", ">16b"))) ;
        write(output, fmt("bv to binary zp    : '{}'" & LF, fbv("10010001", ">016b"))) ;
        write(output, fmt("bv to octal        : '{}'" & LF, fbv("10010001", ">4o"))) ;
        write(output, fmt("bv to octal zp     : '{}'" & LF, fbv("10010001", ">04o"))) ;
        write(output, fmt("bv to hex          : '{}'" & LF, fbv("10010001", ">4x"))) ;
        write(output, fmt("bv to hex zp       : '{}'" & LF, fbv("10010001", ">04x"))) ;

        -- Boolean conversions
        write(output, fmt("boolean to binary  : '{}'" & LF, f(true, ">04b"))) ;

        -- Strings
        write(output, fmt("limited to 4       : '{}'" & LF, fstr("limited", "0.4s"))) ;
        write(output, fmt("limited to 20      : '{}'" & LF, fstr("limited", ">10.20s"))) ;
        write(output, fmt("fill keep spaces < : '{}'" & lF, fstr("    spaces    ", "~<20s"))) ;
        write(output, fmt("fill keep spaces > : '{}'" & lF, fstr("    spaces    ", "~>20s"))) ;
        write(output, fmt("fill keep spaces ^ : '{}'" & lF, fstr("    spaces    ", "~^20s"))) ;

        -- Inline reformatting
        write(output, fmt("reformatted string : {{{:>8s}}}" & LF, "value")) ;
        write(output, fmt("log message        : '{:>10s}@{:>20.9t}: {:~40s}!'" & LF, fstr("uut"), f(10 us), fstr("A silly message to log"))) ;

        -- Ambiguous/Problematic strings
        write(output, fmt("integer/binary amb : '{:>16b}'" & LF, f(1100))) ;
        write(output, fmt("integer/binary amb : '{}'" & LF, f(1100, ">16b"))) ;
        write(output, fmt("integer/octal amb  : '{:>16o}'" & LF, f(1100))) ;
        write(output, fmt("integer/octal amb  : '{}'" & LF, f(1100, ">16o"))) ;
        write(output, fmt("integer/hex amb    : '{:>16x}'" & LF, f(1100))) ;
        write(output, fmt("integer/hex amb    : '{}'" & LF, f(1100, ">16x"))) ;

        -- ANSI Foreground Colors
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.BLACK,  "BLACK",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.RED,    "RED",    ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.GREEN,  "GREEN",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.YELLOW, "YELLOW", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.BLUE,   "BLUE",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.PURPLE, "PURPLE", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.CYAN,   "CYAN",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Bold Colors
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.bold.BLACK,  "BLACK",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.bold.RED,    "RED",    ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.bold.GREEN,  "GREEN",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.bold.YELLOW, "YELLOW", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.bold.BLUE,   "BLUE",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.bold.PURPLE, "PURPLE", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.bold.CYAN,   "CYAN",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.bold.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Underline Colors
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.underline.BLACK,  "BLACK",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.underline.RED,    "RED",    ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.underline.GREEN,  "GREEN",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.underline.YELLOW, "YELLOW", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.underline.BLUE,   "BLUE",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.underline.PURPLE, "PURPLE", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.underline.CYAN,   "CYAN",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.underline.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Background Colors
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.background.BLACK,  "BLACK",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.background.RED,    "RED",    ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.background.GREEN,  "GREEN",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.background.YELLOW, "YELLOW", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.background.BLUE,   "BLUE",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.background.PURPLE, "PURPLE", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.background.CYAN,   "CYAN",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.background.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Intense Colors
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intense.BLACK,  "BLACK",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intense.RED,    "RED",    ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intense.GREEN,  "GREEN",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intense.YELLOW, "YELLOW", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intense.BLUE,   "BLUE",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intense.PURPLE, "PURPLE", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intense.CYAN,   "CYAN",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intense.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Bold Intense Colors
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.boldintense.BLACK,  "BLACK",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.boldintense.RED,    "RED",    ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.boldintense.GREEN,  "GREEN",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.boldintense.YELLOW, "YELLOW", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.boldintense.BLUE,   "BLUE",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.boldintense.PURPLE, "PURPLE", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.boldintense.CYAN,   "CYAN",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.boldintense.WHITE,  "WHITE",  ansi.RESET)) ;

        -- ANSI Intense Background Colors
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intensebg.BLACK,  "BLACK",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intensebg.RED,    "RED",    ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intensebg.GREEN,  "GREEN",  ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intensebg.YELLOW, "YELLOW", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intensebg.BLUE,   "BLUE",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intensebg.PURPLE, "PURPLE", ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intensebg.CYAN,   "CYAN",   ansi.RESET)) ;
        write(output, fmt("colors             : '{}{:~^10s}{}'" & LF, ansi.intensebg.WHITE,  "WHITE",  ansi.RESET)) ;

        -- More colors
        write(output, fmt("colors             : '{}{:~^20s}{}'" & LF, ansi.underline.BLACK & ansi.background.white, "BLACK ON WHITE", ansi.RESET)) ;

        std.env.stop ;
    end process ;

end architecture ;

