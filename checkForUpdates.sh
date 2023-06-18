#!/bin/bash

#CHANGEME!!!
$ZABBIX_SERVER = zabbix.server.local

# Pull the latest images for all services in the docker-compose.yml file
docker-compose pull > /dev/null 2>&1

# Get the IDs of all running containers
container_ids=$(docker ps -q)

# Counter for containers with newer versions
containers_with_update=0

# Iterate over each container ID
for id in $container_ids; do
  # Get the image ID for the container
  image_id=$(docker inspect --format='{{.Image}}' "$id")
  
  # Get the image name for the container
  image_name=$(docker inspect --format='{{.Config.Image}}' "$id")

  # Get the latest available image tag from Docker images
  latest_image=$(docker images --no-trunc --format '{{.ID}}' $image_name | head -n1)

  # Check if a newer version is available
  if [[ "$latest_image" != "$image_id" ]]; then
    echo "Container ID: $id"
    echo "Image ID: $image_id"
    echo "Image Name: $image_name"
    echo "Newer Version: $latest_image"
    echo "---------------------------------"
	echo
	containers_with_update=$((containers_with_update+1))
  else
    echo "Container ID: $id"
    echo "Image ID: $image_id"
    echo "Image Name: $image_name"
    echo "No newer version available."
    echo "---------------------------------"
	echo
  fi
done

#get zabbix HostName
ZBX_HOSTNAME=$(docker exec zabbix-agent /bin/sh -c 'echo $ZBX_HOSTNAME')

# Send appropriate status to Zabbix
if [[ $containers_with_update -gt 0 ]]; then
  docker exec -d zabbix-agent /bin/sh -c "/usr/bin/zabbix_sender -z $ZABBIX_SERVER -s $ZBX_HOSTNAME -k container.updatecount -o $containers_with_update"
else
  docker exec -d zabbix-agent /bin/sh -c '/usr/bin/zabbix_sender -z $ZABBIX_SERVER -s $ZBX_HOSTNAME -k container.updatecount -o 0'
fi
