# execute docker_compose@SERVICE systemctl commands
compose_systemctl() {
 if [ -n "$2" ]
    then 
        local command=$2
    else
        local command='status'
 fi
 if [ -n "$1" ]
    then 
        echo EXECUTING: sudo systemctl $command docker-compose@$1.service
	echo
        sudo systemctl $command docker-compose@$1.service
    else
        echo "no input given!"
 fi 
}

function _cdcontainer() {
    local containers=("/srv/container/$2"*)
        [[ -e ${containers[0]} ]] && COMPREPLY=( "${containers[@]##*/}" )
        }
complete -F _cdcontainer cdcontainer

function cdcontainer () {
    if [ -n "$1" ]
        then cd /srv/container/$1
    else
        echo "no input given!"
    fi 
}
