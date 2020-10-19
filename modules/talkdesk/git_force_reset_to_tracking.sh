#!/usr/bin/env bash

set -euo pipefail

if [ -t 1 ]; then
  BOLD="\033[1m"
  CLEAR="\033[0m"
else
  BOLD=""
  CLEAR=""
fi


CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TRACKING_BRANCH=$(git for-each-ref --format='%(upstream:short)' $(git rev-parse --symbolic-full-name $1))

echo "Forcing the local branch '${BOLD}$1${CLEAR}' to be the same as its tracking branch '${BOLD}$TRACKING_BRANCH${CLEAR}'"
# echo "DEBUG: CURRENT_BRANCH: $CURRENT_BRANCH"
# echo "DEBUG: TRACKING_BRANCH: $TRACKING_BRANCH"

if [[ $CURRENT_BRANCH == $1 ]];
then
  echo "git reset --hard $TRACKING_BRANCH"
  git reset --hard $TRACKING_BRANCH
else
  echo "git branch -f $1 $TRACKING_BRANCH"
  git branch -f $1 $TRACKING_BRANCH
fi
