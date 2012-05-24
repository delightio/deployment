#!/bin/sh

# Remotely deploys gesturedrawer via SSH
echo "When prompted, enter delight user password."
ssh -t delight@b11-4.macminivault.com '~/code/deployment/deploy_gesturedrawer.sh'

