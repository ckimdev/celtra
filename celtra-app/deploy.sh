#!/bin/bash
log(){
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color
  echo -e "\n${GREEN}--------------------------------------------------------------------------------"
  echo -e "                    $1                                "
  echo -e "--------------------------------------------------------------------------------\n${NC}"
}

# Authenticate to AWS to access the docker registry
log "Authenticating on AWS Container Registry"
$(aws ecr get-login --region us-west-1)

# Build the docker image and tag it appropriately
log "Building the docker image"
docker build -t celtra-app . && \
docker tag celtra-app:latest 639231722026.dkr.ecr.us-west-1.amazonaws.com/celtra-app:latest

# Push the updated docker image to the remote registry
log "Pushing the updated docker image to the registry"
docker push 639231722026.dkr.ecr.us-west-1.amazonaws.com/celtra-app:latest && \
scp update-containers.sh ec2-user@celtra-app:/home/ec2-user

# SSH to the ec2 server and run the update-containers script
ssh ec2-user@celtra-app << EOF
  /home/ec2-user/update-containers.sh
EOF
