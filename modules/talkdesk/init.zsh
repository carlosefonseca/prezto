TALKDESK_HOME=$HOME/Code

alias td="cd $TALKDESK_HOME"
alias a="cd $TALKDESK_HOME/agent-mobile-android && pwd"
alias i="cd $TALKDESK_HOME/agent-mobile-ios && pwd"

apr() {
	a
	if [[ $(git status -s) != '' ]]; then
		read "?Working copy is dirty. Continue? "
	fi
	git reset --hard && gh pr checkout $1 && git reset --soft origin/dev
}

ipr() {
	i

	if [[ $(git status -s) != '' ]]; then
		read "?Working copy is dirty. Continue? "
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

	git reset --hard && gh pr checkout $1 && git reset --soft origin/$branch
}

itests () {
	i && cd AgentCore && swift test --generate-linuxmain && cd ../AgentPresentation && swift test --generate-linuxmain && cd ../AgentData && swift test --generate-linuxmain && cd ..
}

path+=("${0:h}")

alias i_run_tests="i ; Scripts/run_domain_tests.sh && Scripts/run_data_tests.sh && Scripts/run_presentation_tests.sh && Scripts/run_component_tests.sh"
alias i_run_clean_tests="i ; cd AgentCore ; swift package clean ; cd ../AgentData ; swift package clean ; cd ../AgentPresentation ; swift package clean ; i_run_tests"

export FASTLANE_USER=carlos.fonseca@talkdesk.com
