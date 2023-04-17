export MOZ_ENABLE_WAYLAND=1
export ANDROID=~/Android
export PATH=~/bin:~/.local/bin:$PATH
export PATH=$PATH:$ANDROID/Sdk/platform-tools

if [ -n "$SSH_CLIENT" ];then
  PREFIX="${HOSTNAME}"
fi

function parse_git_dirty {
  [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ \1$(parse_git_dirty)/"
}
export PS1="$PREFIX\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]$ "

trap 'echo -ne "\033]0;$PREFIX ${PWD/$HOME/\~} $BASH_COMMAND\007"' DEBUG
function show_name(){ 
    if [[ -n "$BASH_COMMAND" ]]; 
    then 
    echo -en "\033]0;$PREFIX ${PWD/$HOME/'~'}\007";
    else 
    echo -en "\033]0;$PREFIX ${PWD/$HOME/\~} $BASH_COMMAND\007"; 
    fi 
}
export PROMPT_COMMAND='show_name'

alias -- yt-dlp-x="yt-dlp -x"
alias k=kubectl
