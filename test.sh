#!/bin/bash

set -e

ghdl -a --std=08 fmt.vhd fmt_test.vhd
ghdl -e --std=08 fmt_test
ghdl -r --std=08 fmt_test
