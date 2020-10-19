TALKDESK_HOME=$HOME/Developer

alias td="cd $TALKDESK_HOME"
alias a="cd $TALKDESK_HOME/agent-mobile-android && pwd"
alias i="cd $TALKDESK_HOME/agent-mobile-ios && pwd"
alias ii="cd $TALKDESK_HOME/agent-mobile-ios-future && pwd"

apr() {
    a
    if [[ $(git status -s) != '' ]]; then
        read "?Working copy is dirty. Continue? "
    fi
    git reset --hard && gh pr checkout $1 && git reset --soft origin/dev
}

ipr() {
    i

    if [ -t 1 ]; then
      BOLD="\e[1m"
      CLEAR="\e[0m"
    else
      BOLD=""
      CLEAR=""
    fi

    if [[ $(git status -s) != '' ]]; then
        read "?Working copy is dirty. Continue? "
    fi

    pr_branch=$(gh pr list | grep "$1" | awk -F$'\t' '{print $3}')
    
    if [ -z $pr_branch ]; then
      echo "Failed to get branch name!"
      return
    fi

    for i in $(git branch --remote | egrep -o "feature.*|develop" | uniq); do
        echo "Looking for branch in $i..."
        gh pr list -B "$i" 2>/dev/null | grep "^$1\s"
        if [ $? -eq 0 ]; then
            branch="$i"
            break
        fi
    done

    if [ -z $branch ]; then
        read "branch?PR not found. What's the base branch? "
    else
        echo "Found on branch $branch"
    fi

    parent_commit=$(git merge-base origin/$branch origin/$pr_branch)

    echo "-> pr_branch $pr_branch"
    echo "-> branch $branch"
    echo "-> parent_commit $parent_commit"

    echo "$BOLD$ git reset hard$CLEAR"
    git reset --hard

    echo "$BOLD$ git checkout --detach \"origin/$pr_branch\"$CLEAR"
    git checkout --detach "origin/$pr_branch"

    echo "$BOLD$ git reset --soft $(git merge-base origin/$branch HEAD)$CLEAR"
    git reset --soft $(git merge-base origin/$branch HEAD)
}

itests () {
    i && cd AgentCore && swift test --generate-linuxmain && cd ../AgentPresentation && swift test --generate-linuxmain && cd ../AgentData && swift test --generate-linuxmain && cd ..
}

path+=("${0:h}")

alias i_run_clean_tests="i ; cd AgentCore ; swift package clean ; cd ../AgentData ; swift package clean ; cd ../AgentPresentation ; swift package clean ; i_run_tests"

alias i_run_tests="i && run_tests"

run_tests() {
  Scripts/run_tests.sh
}


export FASTLANE_USER=carlos.fonseca@talkdesk.com

sim_set_pt_booted() {
    for d in $(xcrun simctl list devices booted | grep Booted | perl -pe "s/.*\(([^ ]+)\) \(Booted\)/\1/")
    do
        sim_set_pt $d
    done
    pkill -9 Simulator
    open -a /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
}

sim_set_pt() {
    if [[ $1 == *" "* ]]; then
        DEVICE=$(sim_get_uid $1);
    else
        DEVICE=$1
    fi

    echo -n $DEVICE
    /usr/libexec/PlistBuddy -c "Set :AppleKeyboards:2 pt_PT@sw=QWERTY;hw=Automatic" -c "Set :AppleKeyboards:3 pt_PT@sw=QWERTY;hw=Automatic" -c "Set :AppleLanguages:1 pt-PT"  $HOME/Library/Developer/CoreSimulator/Devices/$DEVICE/data/Library/Preferences/.GlobalPreferences.plist
    # This is reset on restart (last checked on iOS 13.7)
    /usr/libexec/PlistBuddy -c "Set :AutomaticMinimizationEnabled false"  $HOME/Library/Developer/CoreSimulator/Devices/$DEVICE/data/Library/Preferences/com.apple.Preferences.plist
    echo -n " Files patched. Restarting device… "
    xcrun simctl shutdown $DEVICE

    echo "Done!"
}

sim_get_uid() {
    echo $( xcrun simctl list devices | grep -v -i unavailable | noglob grep -w "$1" | head -n 1 | awk 'match($0, /\(([-0-9A-F]+)\)/) { print substr( $0, RSTART + 1, RLENGTH - 2 )}' )
}

sim_restart() {
    xcrun simctl shutdown $1
    xcrun simctl boot $1
}

sims() {
    xcrun simctl list devices | grep -v -i unavailable
}

