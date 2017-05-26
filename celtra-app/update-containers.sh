#!/bin/bash
log(){
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color
  echo -e "\n${GREEN}--------------------------------------------------------------------------------"
  echo -e "                    $1                                "
  echo -e "--------------------------------------------------------------------------------\n${NC}"
}
$(aws ecr get-login --region us-west-1)
log "Deploying celtra-app on $(curl -s http://instance-data/latest/meta-data/local-ipv4)"


log 'Checking if Nginx LB is running'
lb_response=`curl -s -o /dev/null -I -w "%{http_code}" localhost:80`
if [ $lb_response -ne 200 ]
  then
    log 'Starting nginx LB'
    host_ip="$(curl -s http://instance-data/latest/meta-data/local-ipv4)"
    docker pull 639231722026.dkr.ecr.us-west-1.amazonaws.com/celtra-lb:latest
    docker run --add-host="localhost:"$host_ip"" -d -t -p 80:80 639231722026.dkr.ecr.us-west-1.amazonaws.com/celtra-lb:latest
  else
    log 'Nginx LB is healthy'
fi


# check which port to use

docker pull 639231722026.dkr.ecr.us-west-1.amazonaws.com/celtra-app:latest && \

# get port to use (by seeing whether 8080 is being used)
http=`curl -s -o /dev/null -I -w "%{http_code}" localhost:8080`
if [ $http -eq 200 ]; then newport=8081; oldport=8080; else newport=8080; oldport=8081; fi;

# run docker on port above
docker rm celtra-app-"$newport" &>/dev/null
docker run --name celtra-app-"$newport" -d -p "$newport":80 639231722026.dkr.ecr.us-west-1.amazonaws.com/celtra-app:latest

# sleep while above port is up
pingnew=000
while [ $pingnew -eq 000 ]
do
  pingnew=`curl -s -o /dev/null -I -w "%{http_code}" localhost:"$newport"`
  log "Waiting for the new service to come up on port $newport"
  sleep 5
done

# kill old docker container
log "Taking down the old container celtra-app-$oldport on port $oldport"
docker stop celtra-app-"$oldport" &>/dev/null
docker rm celtra-app-"$oldport" &>/dev/null

log "Zerp Downtime Deployment complete!\nCeltra-app is now running on $(curl -s http://instance-data/latest/meta-data/public-hostname)"

