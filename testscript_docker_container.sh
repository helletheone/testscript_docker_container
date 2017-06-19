#!/bin/bash

###############################################
######Docker-TEST-SCRIPT########
###############################################

# The script checks if a container is running.
#   OK - running
#   WARNING - restarting
#   CRITICAL - stopped
#   UNKNOWN - does not exist
#
#  - Returns unknown (exit code 3) if docker binary is missing, unable to talk to the daemon, or if container id is missing

source=("examplecontainer" "examplecontainer" "examplecontainer" "examplecontainer")

for source in ${source[@]}; do


if [ "x${source[$i]}" == "x" ]; then
  echo "UNKNOWN - Container ID or Friendly Name Required"
  exit 3
fi

if [ "x$(which docker)" == "x" ]; then
  echo "UNKNOWN - Missing docker binary"
  exit 3
fi

docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "UNKNOWN - Unable to talk to the docker daemon"
  exit 3
fi

RUNNING=$(docker inspect --format="{{.State.Running}}" ${source[$i]} 2> /dev/null)

if [ $? -eq 1 ]; then
  echo "UNKNOWN - ${source[$i]} does not exist."
  exit 3
fi

if [ "$RUNNING" == "false" ]; then
  echo "CRITICAL - ${source[$i]} is not running."
  exit 2
fi

RESTARTING=$(docker inspect --format="{{.State.Restarting}}" ${source[$i]})

if [ "$RESTARTING" == "true" ]; then
  echo "WARNING - ${source[$i]} state is restarting."
  exit 1
fi

STARTED=$(docker inspect --format="{{.State.StartedAt}}" ${source[$i]})
NETWORK=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" ${source[$i]})

echo "OK - ${source[$i]} is running. IP: $NETWORK, StartedAt: $STARTED"

done


echo ######################################################
echo All Containers are UP and Running! NICE!
echo ######################################################
