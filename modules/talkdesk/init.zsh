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
	if [[ $# -eq 1 ]]; then
		read "branch?Base branch?"
	else
		branch=$2
	fi
	i
	if [[ $(git status -s) != '' ]]; then
		read "?Working copy is dirty. Continue? "
	fi
	git reset --hard && gh pr checkout $1 && git reset --soft origin/$branch
}

itests () {
	i && cd AgentCore && swift test --generate-linuxmain && cd ../AgentPresentation && swift test --generate-linuxmain && cd ../AgentData && swift test --generate-linuxmain && cd ..
}
