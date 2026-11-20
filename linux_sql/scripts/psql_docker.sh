#!/bin/sh
#Capture CLI arguments
cmd=$1
container_name=$2
db_username=$3
db_password=$4

# Start docker
sudo systemctl start docker || exit 1

#Check container status
	docker container inspect "$container_name" > /dev/null 2>&1
  container_status=$?

#User switch case to handle create|stop|start operations
case $cmd in
  create)

#Check if the container is already created
  if [ $container_status -eq 0 ]; then
		echo 'Container already exists'
		exit 1
	fi

#Check # of CLI arguments
  if [ $# -ne 4 ]; then
    echo 'Create requires username and password'
    exit 1
  fi
  
#Create container
	docker volume create "${container_name}_data" || exit 1
#Start the container
	docker run --name "$container_name" -e POSTGRES_USER="$db_username" -e POSTGRES_PASSWORD="$db_password" -d -v "${container_name}_data:/var/lib/postgresql/data" -p 127.0.0.1:5432:5432 postgres:9.6-alpine
	exit $?
	;;

  start|stop) 
#Check instance status; exit 1 if container has not been created
  if [ $container_status -ne 0 ]; then
        echo 'Container does not exist'
        exit 1
    fi 

#Start or stop the container
	docker container "$cmd" "$container_name"
	exit $?
	;;	
  
  *)
	echo 'Illegal command'
	echo 'Commands: start|stop|create'
	exit 1
	;;
esac 
