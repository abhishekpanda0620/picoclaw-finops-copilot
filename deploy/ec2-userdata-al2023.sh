#!/bin/bash
set -ex

# Output all logs to a userdata log file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting Picoclaw initialization..."

# Update system packages
dnf update -y

# Install required tools
dnf install -y git jq wget tar unzip

# Install AWS CLI v2 (required for FinOps skill)
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip
aws --version

# Install Go (since Picoclaw comprises Go skills/components)
GO_VERSION="1.22.1"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz

# Set up Go environment path
cat << 'EOF' > /etc/profile.d/go.sh
export PATH=$PATH:/usr/local/go/bin
EOF
source /etc/profile.d/go.sh

echo "Go version $(go version) installed."

# Clone the official sipeed/picoclaw repository
echo "Cloning and building PicoClaw..."
cd /opt
git clone https://github.com/sipeed/picoclaw.git picoclaw
cd picoclaw

# Install dependencies and build the binary
make deps || true
make build
make install

# Setup systemd service to run PicoClaw continuously
echo "Configuring systemd service..."
cat << 'EOF' > /etc/systemd/system/picoclaw.service
[Unit]
Description=PicoClaw FinOps Copilot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/picoclaw
ExecStart=/usr/local/bin/picoclaw gateway
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the service, but DO NOT start it yet.
# The user needs to configure their API keys first.
systemctl daemon-reload

echo "Picoclaw installation completed successfully!"
echo "Please run the onboarding setup script to configure your API keys before starting the service."
