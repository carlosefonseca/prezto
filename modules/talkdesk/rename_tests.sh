#!/usr/bin/env bash

set -euo pipefail

R1='s/test_(should_\w+)_when_(\w+)\(/test_WHEN_$2_THEN_$1(/'
R2='s/test_(?:it|presents)_(\w+)_(?:when|after)_(\w+)\(/test_WHEN_$2_THEN_$1(/'
R3='s/test_when_(\w+)_then_(\w+)\(/test_WHEN_$1_THEN_$2(/'
R4='s/test_should_(\w+)_if_(\w+)\(/test_WHEN_$2_THEN_$1(/'
R5='s/test_that_when_(\w+)_then_/test_WHEN_$1_THEN_/'
R6='s/test_it_should_(\w+)_if_(\w+)\(/test_WHEN_$2_THEN_should_$1(/'
R7='s/test_given_(\w+)_when_(\w+)_then_(\w+)/test_GIVEN_$1_WHEN_$2_THEN_$3/'
R8='s/_i_am_/_I_am_/'

perl -pi -e "$R1 ; $R2 ; $R3 ; $R4 ; $R5 ; $R6 ; $R7 ; $R8" $1
