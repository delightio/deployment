#!/bin/sh
# This script deploys gesturedrawer remotely via SSH.
# Usage: deploy_gesturedrawer_remote <delight.web branch> <gesturedrawer branch>

echo "When prompted, enter delight user password."
ssh -t delight@b11-4.macminivault.com "~/code/deployment/deploy_gesturedrawer.sh" "$1" "$2"

