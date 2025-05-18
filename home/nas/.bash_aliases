alias dim='sudo docker images  --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedSince}}\t{{.Size}}\t{{.ID}}"' # docker images custom format
alias dps='sudo docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}\t{{.Networks}}\t{{.Command}}"' # docker containers all custom format
alias drmc='_f() { if [ -n "$1" ]; then docker stop $1 && docker rm $1 ; else echo "no input given!"; fi }; _f' # docker container stop & delete
alias drmi='_f() { if [ -n "$1" ]; then docker rmi $1 ; else echo "no input given!"; fi }; _f' # docker container image remove

alias create_service_dirs='_f() { if [ -n "$1" ]; then sudo mkdir -p /srv/container/$1/{data,docker} ; else echo "no input given!"; fi }; _f' # create container service directories in /srv/container
alias status_compose='_f() { if [ -n "$1" ]; then sudo systemctl status docker-compose@$1.service ; else echo "no input given!"; fi }; _f' # docker container image remove
