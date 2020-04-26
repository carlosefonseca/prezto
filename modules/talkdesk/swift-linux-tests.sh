#!/bin/sh

# Finds changed Tests and regenerates the respective linuxmain
for i in AgentCore AgentPresentation AgentData; do
	cd $i
	git diff --name-only --cached -Gfunc --relative Tests | grep '\.swift$' > /dev/null
	if [ $? -eq 0 ]; then 
		swift test --generate-linuxmain || exit 1
		git add **/XCTestManifests.swift
	fi
	cd ..
done
