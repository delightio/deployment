#!/bin/sh
# This script deploys gesturedrawer remotely via SSH.
# Usage: deploy_gesturedrawer_staging_remote.sh

echo "When prompted, enter delight user password."
ssh -t delight@b11-4.macminivault.com "bash --login -c ~/code/deployment/deploy_gesturedrawer_staging.sh" "$1" "$2"

