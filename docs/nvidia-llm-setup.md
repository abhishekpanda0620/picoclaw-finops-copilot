# NVIDIA LLM Setup

PicoClaw FinOps Copilot uses Large Language Models to interpret AWS Cost Explorer outputs and format them into readable insights. You can use NVIDIA's API endpoints to power this Copilot with high-performance, open-source models like `llama-3.1-nemotron-70b-instruct` or `moonshotai/kimi-k2.5`.

## 1. Obtain an NVIDIA API Key
1. Navigate to the [NVIDIA Build API Portal](https://build.nvidia.com/v1) (or the specific integrations portal depending on your account).
2. Sign in or create an NVIDIA Developer account.
3. Generate a new API Key. It usually begins with `nvapi-`.

## 2. Select a Model
NVIDIA hosts several highly capable reasoning models. We recommend:
*   `nvidia/nemotron-4-340b-instruct`
*   `openai/moonshotai/kimi-k2.5`
*   `meta/llama-3.1-70b-instruct`

## 3. Configuration in PicoClaw
When you run the onboarding script (`deploy/setup-picoclaw.sh`), it will prompt you for an LLM integration.

*   **Model Name:** Enter the exact string of the model (e.g., `nvidia/nemotron-4-340b-instruct`).
*   **API Key:** Enter your `nvapi-...` token.
*   **Custom API Base URL:** Enter `https://integrate.api.nvidia.com/v1`

If you are configuring this manually, update `~/.picoclaw/config.json` on the EC2 server:

```json
{
  "agents": {
    "defaults": {
      "model": "nvidia/nemotron-4-340b-instruct"
    }
  },
  "model_list": [
    {
      "model_name": "nvidia/nemotron-4-340b-instruct",
      "model": "nvidia/nemotron-4-340b-instruct",
      "api_key": "nvapi-YOUR-API-KEY",
      "api_base": "https://integrate.api.nvidia.com/v1"
    }
  ]
}
```

Restart the service after applying changes manually:
```bash
sudo systemctl restart picoclaw
```
