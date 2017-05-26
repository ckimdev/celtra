#!/bin/bash
log(){
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color
  echo -e "\n${GREEN}--------------------------------------------------------------------------------"
  echo -e "                    $1                                "
  echo -e "--------------------------------------------------------------------------------\n${NC}"
}

# Authenticate to AWS to access the remote docker registry
$(aws ecr get-login --region us-west-1)
log "Deploying celtra-app on $(curl -s http://instance-data/latest/meta-data/local-ipv4)"


# Check if Nginx Reverse Proxy is running
# This reverse proxy should always be running
# But this check is here to be safe
log 'Checking if Nginx Reverse Proxy is running'
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


# Pull the latest docker image for the application
docker pull 639231722026.dkr.ecr.us-west-1.amazonaws.com/celtra-app:latest && \

# Figure out which port the old application is running on [8080? 8081]
http=`curl -s -o /dev/null -I -w "%{http_code}" localhost:8080`
if [ $http -eq 200 ]; then newport=8081; oldport=8080; else newport=8080; oldport=8081; fi;

# Run the new docker image on the new port that's not being used
docker rm celtra-app-"$newport" &>/dev/null
docker run --name celtra-app-"$newport" -d -p "$newport":80 639231722026.dkr.ecr.us-west-1.amazonaws.com/celtra-app:latest

# While the new application is coming up, sleep!
pingnew=000
while [ $pingnew -eq 000 ]
do
  pingnew=`curl -s -o /dev/null -I -w "%{http_code}" localhost:"$newport"`
  log "Waiting for the new service to come up on port $newport"
  sleep 5
done

# Now that the new application is up and running,
# Kill the older application and remove its docker image
log "Taking down the old container celtra-app-$oldport on port $oldport"
docker stop celtra-app-"$oldport" &>/dev/null
docker rm celtra-app-"$oldport" &>/dev/null

log "Zerp Downtime Deployment complete!\nCeltra-app is now running on $(curl -s http://instance-data/latest/meta-data/public-hostname)"

