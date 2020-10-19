#!/usr/bin/env bash


# cd AgentCore
# swiftlint autocorrect --config "../Agent/.swiftlint.yml"
# cd ..

# cd AgentData
# swiftlint autocorrect --config "../Agent/.swiftlint.yml"
# cd ..

# cd AgentPresentation
# swiftlint autocorrect --config "../Agent/.swiftlint.yml"
# cd ..

# cd AgentComponentTests
# swiftlint autocorrect --config "../Agent/.swiftlint.yml"
# cd ..

# cd Agent
# swiftlint autocorrect --config "../Agent/.swiftlint.yml"
# cd ..

# exit


# RULE=trailing_whitespace;
# RULE=colon;
# RULE=opening_brace
RULE=unused_closure_parameter
( echo "disabled_rules:"; swiftlint rules | /usr/bin/grep -o -E '^\|[^|]*\| no' | cut -d" " -f1,2 | sed -e 's#|# -#' | grep -v "${RULE}" ) > ".swiftlint-only-${RULE}.yml"

cd AgentCore
swiftlint autocorrect --config "../.swiftlint-only-${RULE}.yml"
cd ..

cd AgentData
swiftlint autocorrect --config "../.swiftlint-only-${RULE}.yml"
cd ..

cd AgentPresentation
swiftlint autocorrect --config "../.swiftlint-only-${RULE}.yml"
cd ..

cd AgentComponentTests
swiftlint autocorrect --config "../.swiftlint-only-${RULE}.yml"
cd ..

cd Agent
swiftlint autocorrect --config "../.swiftlint-only-${RULE}.yml"
cd ..

rm -f ".swiftlint-only-${RULE}.yml"
