#!/bin/bash

set -e

ghdl -a --std=08 fmt.vhd fmt_test.vhd fmt_examples.vhd

ghdl -e --std=08 fmt_test
ghdl -e --std=08 fmt_examples

ghdl -r --std=08 fmt_test
ghdl -r --std=08 fmt_examples
