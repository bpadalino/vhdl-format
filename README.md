# VHDL String Formatting Package
This is a VHDL string formatting package that is based on [f-strings found in Python 3](https://docs.python.org/3/reference/lexical_analysis.html#f-strings).

## Problem
Working with strings in VHDL is somewhat difficult.  They require known sizes, are
concatenated with the `&` operator, and can be difficult to align concisely.

A typical string building line might look like:
```vhdl
  report "int: " & integer'image(int) & " real: " & real'image(r);
```

## Solution
VHDL has operator overloading which includes the return style, so we can emulate
the style of f-strings in VHDL.

```vhdl
report f("int: {} real: {}", f(int), f(r));
```

Here, we have defined the function `f()` for all the standard types included with
VHDL as well as a function that uses the formatted string as the first argument.
In fact, we can extend this further and insert formatting information into the
string itself, or when we perform the initial conversion on the type.

```vhdl
report f("int: {:>12d} real: {}", f(int), f(r, "0.12f"));
```

In this example, we are right justifying a signed decimal number with a width of 12,
and creating a string from the value `r` with 12 bits of precision after the decimal
point.

## `fmt` package

The `fmt` package defines the following functions for use.

```vhdl
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
```

These are all included in a single file: [`fmt.vhd`](https://github.com/bpadalino/vhdl-format/blob/main/fmt.vhd).

## Format Specification

The format specification is close to the Python 3 format specification, but not
exactly.

```
[fill][align][sign][width][.precision][class]
```

__fill__: Any character

The character to fill any extra space when the string does not fit the requested width.

Example:
```vhdl
fmt("{:~20s}", "string")
```

Output: `string~~~~~~~~~~~~~~`

__align__: `<` `>` `^` `=`

Left Justification (`<`), Right Justification (`>`), Centered (`^`), and Sign Align
Justification (`=`, for `d`, `e`, `f`, `u` classes only)

__sign__: `+`

Always print the sign of a number (for `d`, `e`, `f`, `u` classes only)

__width__: A number

The minimum number of characters to write.

__.precision__: A point then a number

For the (`e`, `f`) classes, defines the number of places to the right of the decimal.
For the `t` class, determines which timebase to utilize for the conversion.

| Precision | Time Unit     |
|-----------|---------------|
| `.0`      | 1 second      |
| `.3`      | 1 millisecond |
| `.6`      | 1 microsecond |
| `.9`      | 1 nanosecond  |
| `.12`     | 1 picosecond  |
| `.15`     | 1 femtosecond |

__class__: `b`, `c`, `d`, `e`, `f`, `o`, `s`, `t`, `u`, `x`

The class of the string represented.

| Character | Class                                            |
|-----------|--------------------------------------------------|
| `b`       | Binary                                           |
| `c`       | Character                                        |
| `d`       | Signed integer                                   |
| `e`       | Floating point (exp notation - i.e. 3.14159e+00) |
| `f`       | Floating point (fixed notation - i.e. 3.14159)   |
| `o`       | Octal                                            |
| `s`       | String                                           |
| `t`       | Time value                                       |
| `u`       | Unsigned integer                                 |
| `x`       | Hexadecimal                                      |

Note: Both uppercase and lowercase versions of the class are accepted.

## Usage
The usage of the package should be straight forward and easy.  The main goal is
easier string manipulation, so being able to do simple string substitutions is
the easiest way to use the package.

```vhdl
report f("{} {}", "hello", "world");
```

Argument reordering can also be done.

```vhdl
report f("{1} {0}", "world", "hello");
```

Formatting can be done inline.

```vhdl
report f("{:<20s} {:>20s}", "hello", "world");
```

Formatting may also be done on the argument.

```vhdl
report f("{} {}", fstr("hello","<20s"), fstr("world",">20s));
```

Lastly, for convenience, single argument overloads are available, too.

```vhdl
report f("realnum: {:12.8f}", 3.14159)); 
```

For more examples, please see the [`fmt_examples.vhd`](https://github.com/bpadalino/vhdl-format/blob/main/fmt_examples.vhd)
file.

## TODO Items
* [ ] Binary/Octal/Hex Conversions for Integers
* [ ] Add `std_logic_vector` `f()`
* [ ] Add `signed` and `unsigned` `f()`
* [ ] Add `sfixed` and `ufixed` `f()`
* [ ] Generic `f()` for easier customization with default `'image` or `to_string()` conversions
* [ ] Add the `#` option for printing `0b`, `0o`, or `0x` before the printed number

## License
The package is provided under the Unlicense so feel free to do whatever you like with it.
If you like the project, please let me know.  If you run into issues, please feel free to
file an issue as well.
