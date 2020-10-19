#!/usr/bin/env bash

if [ -t 1 ]; then
  BOLD="\033[1m"
  CLEAR="\033[0m"
else
  BOLD=""
  CLEAR=""
fi
echo -e "${BOLD}HELLO!$CLEAR"
