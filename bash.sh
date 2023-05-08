# использовать как ~/.bash_login!
export HISTCONTROL=ignoreboth:erasedups
if [[ ! -L "$HOME/.bashrc" ]] \
    || [[ `readlink "$HOME/.bashrc"` != ".bash_login" ]]; then
  cd $HOME
  rm -rf .bashrc
  ln -sf .bash_login .bashrc
fi

[ -z "$PS1" ] && return
. /etc/bash_completion
export MOZ_ENABLE_WAYLAND=1
export ANDROID=~/Android
export PATH=~/bin:~/.local/bin:$PATH
export PATH=$PATH:$ANDROID/Sdk/platform-tools

is_in_ssh() (
  [ -n "$SSH_CONNECTION" ] && exit 0
  [ -n "$ZSH_VERSION"  ] && setopt shwordsplit
  declare -A CHILDS
  declare -A COMMS
  while read P PP PPP;do
    CHILDS[$P]+=" $PP"
    COMMS[$P]+=" $PPP"
  done < <(ps -e -o pid= -o ppid= -o comm=)
  walk() {
    [[ "${COMMS[$1]}" =~ .*sshd.* ]] && exit 0;
    for i in ${CHILDS[$1]};do
      walk $i
    done
  }
  for i in "$@";do
    walk $i
  done
  exit 1
)
is_in_ssh $$ && PREFIX=$HOSTNAME"┃"

function parse_git_dirty {
  [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ \1$(parse_git_dirty)/"
}
function ps1 {
  [[ $? == 0 ]] && color='32m' || color='31m'
  # \001 instead of \[ and \002 instead of \]
  printf "$PREFIX\001\033[32m\002${PWD/$HOME/\~}\001\033[33m\002$(parse_git_branch)\001\033[$color\002"
}
export PS1='$(ps1)\$\001\033[00m\002 '

trap 'echo -ne "\033]0;$PREFIX${PWD/$HOME/\~} $BASH_COMMAND\007"' DEBUG
function show_name(){
    if [[ -n "$BASH_COMMAND" ]];
    then
    echo -en "\033]0;$PREFIX${PWD/$HOME/\~}\007";
    else
    echo -en "\033]0;$PREFIX$BASH_COMMAND\007";
    fi
}
export PROMPT_COMMAND='show_name'

alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ip='ip -color=auto'
alias -- yt-dlp-youtube="yt-dlp -x -o '%(upload_date)s-%(title)s-%(id)s.%(ext)s'"

if [ -f ~/.kube/config ];then
. <(kubectl completion bash)
  alias k=kubectl
  complete -o default -F __start_kubectl k
fi
