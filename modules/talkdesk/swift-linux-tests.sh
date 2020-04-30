#!/bin/sh

# Finds changed Tests and regenerates the respective linuxmain
for i in AgentCore AgentPresentation AgentData AgentComponentTests; do
    if [ -d $i ]; then
        cd $i
        git diff --name-only --cached --relative Tests | grep '\.swift$' > /dev/null
        if [ $? -eq 0 ]; then 
            swift test --generate-linuxmain || exit 1
            git add **/XCTestManifests.swift
        fi
        cd ..
    fi
done
