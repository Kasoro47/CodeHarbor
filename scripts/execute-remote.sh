#!/bin/bash
# Variables
REMOTE_USER=debian
REMOTE_IP=57.128.61.186
REMOTE_SCRIPT_PATH="~/codeharbor-kind-deploy.sh"

# SSH remote command
ssh ${REMOTE_USER}@${REMOTE_IP} "bash ${REMOTE_SCRIPT_PATH}"

echo "Executed remote script"
