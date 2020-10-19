#!/usr/bin/env bash

export GEM_HOME=/Users/carlos.fonseca/.gems

cd $1

/Users/carlos.fonseca/.zprezto/modules/talkdesk/clean_change_log.rb Docs/qa-changelog.txt
