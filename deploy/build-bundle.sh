#!/bin/bash
set -e

echo "Building PicoClaw FinOps deployment bundle..."

# Move to the root of the project
cd "$(dirname "$0")/.."

# Ensure deploy directory exists
mkdir -p deploy/dist

# Remove any old zip
rm -f deploy/dist/picoclaw-deploy.zip

# Zip the required files (junk paths so they end up in the same dir)
zip -j deploy/dist/picoclaw-deploy.zip deploy/setup-picoclaw.sh skills/finops/SKILL.md

echo "Successfully created deploy/dist/picoclaw-deploy.zip!"
echo "You can SCP this file to your EC2 instance:"
echo "scp -i your-key.pem deploy/dist/picoclaw-deploy.zip ubuntu@<EC2-IP>:~/"
