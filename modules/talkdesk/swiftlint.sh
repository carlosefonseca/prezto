#!/bin/bash

# Can be used as pre-commit or standalone

SWIFTLINT_CONFIG=$HOME/Code/.swiftlint.yml

#Path to swiftlint
SWIFT_LINT=/usr/local/bin/swiftlint

if [ $# -ge 1 ]; then
    if [ $1 = "amend" ]; then
        input=$(git diff --name-only HEAD HEAD~1 | grep ".swift$")
    elif [ $1 = "-" ]; then
        input=$(cat - | grep ".swift$")
    elif [ $1 = "--help" ]; then
        echo "Call without arguments to run on staged files."
        echo "Call with 'amend' to run on files of the previous commit."
        echo "Call with '-' to run on files passed through STDIN."
        exit 0
    else
        echo "Invalid argument!"
        exit 1
    fi
else
    input=$(git diff --name-only --cached | grep ".swift$");
fi


#if $SWIFT_LINT >/dev/null 2>&1; then
if [[ -e "${SWIFT_LINT}" ]]; then

##### Check for modified files in unstaged/Staged area #####

    count=0
    for file_path in $input; do
        if [ -f "$file_path" ]; then
            export SCRIPT_INPUT_FILE_$count=$file_path
            # echo $file_path
            count=$((count + 1))
        fi
    done

##### Make the count avilable as global variable #####
    export SCRIPT_INPUT_FILE_COUNT=$count

    # echo "${SCRIPT_INPUT_FILE_COUNT}"
    # env | grep SCRIPT_INPUT_FILE

##### Lint files or exit if no files found for lintint #####
    if [ "$count" -ne 0 ]; then
        # echo "Found lintable files! Linting..."
        # $SWIFT_LINT autocorrect --strict --use-script-input-files --config $SWIFTLINT_CONFIG #--reporter json
        $SWIFT_LINT lint --strict --use-script-input-files --config $SWIFTLINT_CONFIG --quiet
    else
        echo "No files to lint!"
        exit 0
    fi

    RESULT=$?
    $SWIFT_LINT autocorrect --use-script-input-files --config $SWIFTLINT_CONFIG --quiet > /dev/null

    if [ $RESULT -eq 0 ]; then
        echo ""
        echo "Violation found of the type WARNING! Consider fixing them before commit!"
    else
        echo ""
        echo "Violation found of the type ERROR! Must fix before commit!"
    fi
    exit $RESULT

else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
