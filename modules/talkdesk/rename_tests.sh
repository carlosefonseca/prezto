#!/usr/bin/env bash

set -euo pipefail

R1='s/test_(should_\w+)_when_(\w+)\(/test_WHEN_$2_THEN_$1(/'
R2='s/test_it_(\w+)_when_(\w+)\(/test_WHEN_$2_THEN_$1(/'
R3='s/test_when_(\w+)_then_(\w+)\(/test_WHEN_$1_THEN_$2(/'
R4='s/test_should_(\w+)_if_(\w+)\(/test_WHEN_$2_THEN_$1(/'
R5='s/test_that_when_(\w+)_then_/test_WHEN_$1_THEN_/'
R6='s/test_it_should_(\w+)_if_(\w+)\(/test_WHEN_$2_THEN_should_$1(/'

perl -pi -e "$R1 ; $R2 ; $R3 ; $R4 ; $R5 ; $R6" $1
