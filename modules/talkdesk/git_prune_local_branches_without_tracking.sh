#!/usr/bin/env bash

git fetch --prune && git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D

if (git branch | grep develop); then
  git branch -f develop origin/develop
fi
