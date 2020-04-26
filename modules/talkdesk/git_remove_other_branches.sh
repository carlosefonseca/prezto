#!/usr/bin/env bash

git branch | grep -v '^*' | xargs git branch -D
