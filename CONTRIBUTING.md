# Contributing to PicoClaw FinOps Copilot

First off, thank you for considering contributing to the PicoClaw FinOps Copilot! It's people like you that make this tool incredibly useful for DevOps and FinOps teams everywhere.

## Development Setup

To run and develop PicoClaw FinOps Copilot locally, you will need:

*   **AWS CLI v2:** Configured with an IAM profile that has Cost Explorer access (e.g., `ce:GetCostAndUsage`).
*   **Go (1.22+):** Required if you are modifying core PicoClaw binary logic.
*   **Terraform:** Required if you are modifying the deployment infrastructure.
*   **jq:** Used in deployment and setup scripts.
*   **A connected LLM API Key:** (OpenAI, Anthropic, or NVIDIA) for testing.

### Local Development Flow

For local testing without deploying to EC2:

1.  **Clone the repo:**
    ```bash
    git clone https://github.com/your-org/picoclaw-finops-copilot.git
    cd picoclaw-finops-copilot
    ```

2.  **Initialize the local agent workspace:**
    If you have the PicoClaw binary installed locally, initialize it:
    ```bash
    picoclaw onboard
    ```
    Then, configure `~/.picoclaw/config.json` with your LLM keys.

3.  **Link your local FinOps skills:**
    Copy or symlink the FinOps `SKILL.md` into your local agent workspace to test changes iteratively:
    ```bash
    mkdir -p ~/.picoclaw/workspace/skills/finops
    ln -s $(pwd)/skills/finops/SKILL.md ~/.picoclaw/workspace/skills/finops/SKILL.md
    ```

4.  **Test the prompt natively:**
    Run the agent locally to verify your changes:
    ```bash
    picoclaw agent -m "Calculate my top 5 AWS services by cost for the last 3 days"
    ```

## Adding New FinOps Capabilities

The core logic of the FinOps Copilot relies entirely on the deterministic shell executions defined in `skills/finops/SKILL.md`.

When adding a new capability (e.g., ElastiCache analysis, DynamoDB tracking):

1.  **Build your AWS CLI command first.** Test it thoroughly in your terminal to assure the JSON output shape is correct and the calculations are exact.
2.  **Edit `SKILL.md`.** Add a new section outlining the natural language triggers, exact AWS CLI commands required, and strictly formatted Slack output instructions.
3.  **Update IAM Policies.** If your new command requires new AWS permissions (e.g., `elasticache:Describe*`), update `deploy/iam-policy.json`.
4.  **Local Test.** Run the prompt locally using `picoclaw agent -m "..."` to ensure the LLM successfully executes your new commands and formats the data appropriately.

## Pull Request Process

1.  **Fork the repository** and create your branch from `main`.
2.  **Branch Naming:** Use a descriptive prefix like `feat/`, `fix/`, or `docs/` (e.g., `feat/add-dynamodb-cost-tracking`).
3.  **Documentation:** If you add a new FinOps capability, update the root `README.md` to reflect the new feature.
4.  **Commit Messages:** Write clear, concise commit messages.
5.  **Submit PR:** Open your pull request. Provide a clear description of the problem you are solving and screenshots of the Slack output if you added new AWS CLI tracking capabilities.

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. Be respectful and constructive in your code reviews and discussions.
