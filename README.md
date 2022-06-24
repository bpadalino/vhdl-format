This is a proof of concept for formatting strings with VHDL.

The format specifier follows Python's format strings for the most part.

    [fill][align][sign][width][.precision][class]

`align` can be one of `<`, `>`, `^`, `=`.

`sign` can be `#`.

`class` can be `b` for binary, `c` for character, `d` for signed integer, `f`
for floating point, `o` for ocal, `s` for string, `u`, for unsigned integer,
and `x` for hexadecimal.

General usage is like this:

```
write(output, f("{1:~^20d} and {0:>8.20f} are both arguments" & CR & LF, f(3.14159), f(200))) ;
```

The previous should create the string:

```
~~~~~~~~200~~~~~~~~~ and 3.14159000000000000000 are both arguments
```

Note the argument swapping occurred.  Formatting can also be done on just the types themselves,
or the overall format string.

VHDL-2008 is required.

Currently works with GHDL using the following commands:

```
$ ghdl -a --std=08 fmt.vhd fmt_test.vhd
$ ghdl -e --std=08 fmt_test
$ ghdl -r --std=08 fmt_test
Tests:       10   Passed:       10   Failed:        0
simulation stopped @0ms
```
