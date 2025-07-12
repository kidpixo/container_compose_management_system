# vim: foldenable foldmethod=marker foldlevel=0 foldclose=all filetype=sh:

#alias aliasls='grep "^alias" $HOME/.bash_common | cut -d" " -f 2- | sort | sed "s/=/+/" | column -s"+" -t'
aliasls () { (echo 'alias name+command'; grep "^alias" $HOME/.bash_aliases | cut -d" " -f 2- | sort | sed "s/=/+/") | column -s"+" -t; }

# secure rm: move to Trash
trash () { mv "$@" ~/.Trash;}

LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43" export LS_COLORS
# ls aliases {{{
export LS_OPTIONS="-h --color=always -A"
export TIME_STYLE='+%d-%b-%Y %H:%M'
export LS_OPTIONS='-h --color=always'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -1'
alias lt='ls $LS_OPTIONS -rt1'
alias llt='ls $LS_OPTIONS -rtl'
alias lltt='ls $LS_OPTIONS -rtl | tail'
alias cutcol="cut -c 1-$(tput cols)" # cut output to screen width
# 30 Handy Bash Shell Aliases For Linux / Unix / Mac OS X – nixCraft > https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html
alias cgrep='grep --colour=always'
alias c='clear'
alias mkdir='mkdir -pv'
# handy short cuts #
alias h='history'
alias j='jobs -l'
alias p5='ping -c 5' # Stop after sending count ECHO_REQUEST packets #
alias fastp='ping -c 100 -s.2' # Do not wait interval 1 second, go fast #
alias rm='rm -i' ## this one saved by butt so many times
alias wget='wget -c'
alias du1='du -h -d 1'
export LESS='-JMQRSXgFN'
alias less='less $LESS'
# go and show all
cdl()    {
  cd"$@";
    ls -al;
}
alias ..='cd ..'
alias ...='cd ../../../'

alias v='vim'
alias vtmux='vim ~/.tmux.conf'
alias vvim='vim ~/.vimrc'
alias vssh='vim ~/.ssh/config '
alias vbash='vim ~/.bash_common'
alias g='git'
complete -o bashdefault -o default -o nospace -F _git g

alias dim='sudo docker images  --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedSince}}\t{{.Size}}\t{{.ID}}"' # docker images custom format
alias dps='sudo docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}\t{{.Networks}}\t{{.Command}}"' # docker containers all custom format
alias drmc='_f() { if [ -n "$1" ]; then docker stop $1 && docker rm $1 ; else echo "no input given!"; fi }; _f' # docker container stop & delete
alias drmi='_f() { if [ -n "$1" ]; then docker rmi $1 ; else echo "no input given!"; fi }; _f' # docker container image remove

alias create_service_dirs='_f() { if [ -n "$1" ]; then sudo mkdir -p /srv/container/$1/{data,docker} ; else echo "no input given!"; fi }; _f' # create container service directories in /srv/container
alias status_compose='_f() { if [ -n "$1" ]; then sudo systemctl status docker-compose@$1.service ; else echo "no input given!"; fi }; _f' # docker container image remove
alias lzd='sudo docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v /srv/container/lazydocker/data:/.config/jesseduffield/lazydocker lazyteam/lazydocker'

# whichfunc :find function definition{{{
whichfunc () ( shopt -s extdebug; declare -F "$1"; )
complete -A function whichfunc # complete with shell functions
#}}}
#
