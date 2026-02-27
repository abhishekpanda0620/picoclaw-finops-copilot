# PicoClaw FinOps Copilot Deployment Guide

This guide covers how to deploy the PicoClaw FinOps Copilot on an AWS EC2 instance using Terraform. It provisions the server, sets up the necessary IAM roles and permissions, and injects the initialization scripts to prepare the environment.

## Prerequisites

1.  **AWS CLI Configured:** Ensure you have the AWS CLI installed and configured with credentials that have sufficient permissions to create EC2 instances, Security Groups, and IAM Roles.
2.  **Terraform Installed:** Ensure you have [Terraform](https://www.terraform.io/downloads) installed (v1.0+ recommended).
3.  **SSH Key Pair:** You need an existing EC2 Key Pair in the region you intend to deploy to (default is `us-east-1`).

## Infrastructure Architecture

*   **EC2 Instance:** A `t3.medium` (configurable) functioning as the Copilot engine.
*   **Operating System:** Supports both Amazon Linux 2023 (`amazon-linux`) and Ubuntu 22.04 LTS (`ubuntu`).
*   **IAM Role:** An Instance Profile is automatically generated and attached to the EC2 instance, mapping the permissions outlined in `deploy/iam-policy.json` directly to the server.
*   **Security Group:** Exposes SSH (22), HTTP (80), and HTTPS (443).

## Steps to Deploy

1.  **Navigate to the Terraform directory:**
    ```bash
    cd deploy/terraform
    ```

2.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

3.  **Review the Plan:**
    You must provide the name of your pre-existing SSH Key Pair. You can also specify the `os_type` to switch between Amazon Linux and Ubuntu.

    ```bash
    # To deploy with Amazon Linux 2023 (default)
    terraform plan -var="key_name=my-ssh-key"

    # To deploy with Ubuntu 22.04 LTS
    terraform plan -var="key_name=my-ssh-key" -var="os_type=ubuntu"
    ```

4.  **Apply the Configuration:**
    If the plan looks correct, apply it to provision the infrastructure.
    ```bash
    terraform apply -var="key_name=my-ssh-key"
    ```
    *Type `yes` when prompted.*

5.  **Access the Server:**
    Once applied, Terraform will output the public IP of the newly created instance.
    ```bash
    # For Amazon Linux:
    ssh -i /path/to/my-ssh-key.pem ec2-user@<instance_public_ip>

    # For Ubuntu:
    ssh -i /path/to/my-ssh-key.pem ubuntu@<instance_public_ip>
    ```

## IAM Policy Customization

The FinOps copilot requires permissions to query AWS services. The base policy (`deploy/iam-policy.json`) currently includes read access to:
*   Cost Explorer (`ce:*`)
*   EC2 / EBS / Snapshots (`ec2:Describe*`)
*   CloudWatch Metrics (`cloudwatch:GetMetricStatistics`)
*   Pricing API
*   RDS (`rds:Describe*`)
*   S3 (`s3:ListAllMyBuckets`)

If you build new FinOps skills (e.g., ElastiCache analysis, DynamoDB tracking), simply edit `deploy/iam-policy.json` to include the appropriate `Describe` or `Get` permissions and run `terraform apply` again to update the EC2 instance's role seamlessly.

## Post-Deployment (Userdata)
Upon boot, the server will automatically run the chosen userdata script (`ec2-userdata-al2023.sh` or `ec2-userdata-ubuntu.sh`). This script installs:
*   Git, wget, jq, curl, tar
*   Go (v1.22.1)
*   Clones and builds the official [sipeed/picoclaw](https://github.com/sipeed/picoclaw) AI assistant via `make deps`, `make build`, and `make install`.

You can check the progress or debug the installation by logging into the server and inspecting `/var/log/user-data.log`.

**Note:** The PicoClaw service will be installed but will *not* start automatically. You must configure your API keys first.

## Onboarding Setup (Required)

Before PicoClaw can operate, it requires an LLM Provider configuration and the FinOps Skill installed. We have created a bundle script to zip these up so you can transfer them to your EC2 instance easily.

1. **Build the Deployment Bundle locally:**
   ```bash
   chmod +x deploy/build-bundle.sh
   ./deploy/build-bundle.sh
   ```
   *This creates `deploy/dist/picoclaw-deploy.zip` containing your `SKILL.md` and `setup-picoclaw.sh`.*

2. **Transfer the Bundle to your EC2 instance:**
   ```bash
   scp -i /path/to/my-ssh-key.pem deploy/dist/picoclaw-deploy.zip ubuntu@<instance_public_ip>:~/
   ```

3. **SSH into the instance and run the setup:**
   ```bash
   ssh -i /path/to/my-ssh-key.pem ubuntu@<instance_public_ip>
   unzip picoclaw-deploy.zip
   chmod +x deploy/setup-picoclaw.sh
   ./deploy/setup-picoclaw.sh
   ```

4. **The script will ask for:**
   *   Your Model Name (e.g., `openai/gpt-4o`, `nvidia/nemotron-4-340b-instruct`)
   *   Your API Key
   *   Optional: Custom API Base URL
   *   Whether you want to enable DuckDuckGo search.

Once completed, the script will copy your `SKILL.md` into the PicoClaw workspace and automatically start the `picoclaw` systemd service in the background!

### Managing the PicoClaw Service
PicoClaw runs automatically in the background as a `systemd` service (`picoclaw.service`) after onboarding.

You can control the **PicoClaw Gateway** using the following commands:

*   **Check Status:** `sudo systemctl status picoclaw`
*   **Stop PicoClaw:** `sudo systemctl stop picoclaw`
*   **Start PicoClaw:** `sudo systemctl start picoclaw`
*   **Restart PicoClaw:** `sudo systemctl restart picoclaw`
*   **View Live Logs:** `sudo journalctl -u picoclaw -f`
