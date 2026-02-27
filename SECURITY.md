# Security Policy

## Supported Versions

Currently, only the main branch (`main`) is actively supported for security updates.

| Version | Supported          |
| ------- | ------------------ |
| `main`  | :white_check_mark: |
| `< 1.0` | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within PicoClaw FinOps Copilot, please do **not** open a public issue.

Instead, please send an email to the repository maintainers or use GitHub's private vulnerability reporting feature if enabled. We will respond to your report as quickly as possible, usually within 48 hours.

When reporting an issue, please provide:
*   A clear description of the vulnerability.
*   Steps to reproduce the issue.
*   The potential impact of the vulnerability.

We value your time and effort in responsibly disclosing security issues.

## Security Architecture & Best Practices

PicoClaw FinOps Copilot is designed with a "least privilege" security model.

1.  **IAM Role-Based Access:** 
    The Copilot operates strictly using an AWS IAM Instance Profile attached to its EC2 instance. **Never** hardcode or store long-lived AWS Access Keys or Secret Keys in the environment variables or configuration files.
    
2.  **Read-Only Permissions by Default:**
    The provided IAM Policy (`deploy/iam-policy.json`) grants read-only access to Cost Explorer, CloudWatch, EC2, RDS, and S3 metadata explicitly. The Copilot cannot modify, launch, or delete AWS resources using this policy.

3.  **Destructive Actions Guardrail:**
    If you extend the IAM policy or FinOps `SKILL.md` to include resource modification (e.g., terminating idle EC2 instances or deleting unused EBS volumes), ensure the skill is configured to **always require explicit user confirmation** before execution.

4.  **Local Workspace Sandbox:**
    The PicoClaw agent executes within a sandboxed local workspace (`~/.picoclaw/workspace`). It is configured by default to restrict file modifications to this directory. Do not override `restrict_to_workspace: false` in the `config.json` unless absolutely necessary.

5.  **LLM Security:**
    Be mindful of the data returned by the AWS CLI that is passed to your configured LLM Provider. Cost and usage data for an AWS Account is considered sensitive. Ensure you are using an enterprise-grade LLM provider (e.g., Anthropic, OpenAI, or a self-hosted instance) that complies with your organization's data privacy policies.
