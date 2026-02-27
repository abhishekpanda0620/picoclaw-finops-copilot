#!/bin/bash
set -e

echo "=================================================="
echo "    PicoClaw FinOps Copilot Setup & Onboarding    "
echo "=================================================="
echo ""

echo "Initializing PicoClaw workspace..."
/usr/local/bin/picoclaw onboard

CONFIG_DIR="$HOME/.picoclaw"
CONFIG_FILE="$CONFIG_DIR/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config.json not found after onboard command."
    exit 1
fi

echo ""
echo "We need to set up your LLM Provider for PicoClaw."
echo "You can use OpenAI, Anthropic, OpenRouter, or alternative providers like OpenRouter or Nvidia."
echo ""
read -p "Enter your Model Name (e.g., openai/gpt-4o, openai/moonshotai/kimi-k2.5): " MODEL_NAME
read -s -p "Enter your API Key: " API_KEY
echo ""
read -p "Enter a custom API Base URL (leave blank for defaults, useful for Nvidia/Ollama proxying): " API_BASE
echo ""

read -p "Do you want to enable DuckDuckGo Web Search? (Y/n): " ENABLE_SEARCH
ENABLE_SEARCH=${ENABLE_SEARCH:-Y}
DDG_ENABLED="true"
if [[ "$ENABLE_SEARCH" =~ ^[Nn]$ ]]; then
    DDG_ENABLED="false"
fi

# Use jq to robustly inject the new model and search settings into the natively generated config.json
# We use conditional logic to ensure missing parent objects don't break the JSON structure.
TMP_FILE=$(mktemp)

# Construct the model object. Only add api_base if it is not empty
if [ -z "$API_BASE" ]; then
    MODEL_JSON="{\"model_name\": \"$MODEL_NAME\", \"model\": \"$MODEL_NAME\", \"api_key\": \"$API_KEY\"}"
else
    MODEL_JSON="{\"model_name\": \"$MODEL_NAME\", \"model\": \"$MODEL_NAME\", \"api_key\": \"$API_KEY\", \"api_base\": \"$API_BASE\"}"
fi

jq --arg model "$MODEL_NAME" \
   --argjson model_obj "$MODEL_JSON" \
   --argjson ddg "$DDG_ENABLED" \
   '(if .agents.defaults then . else .agents = {"defaults": {}} end) |
    .agents.defaults.model = $model | 
    (if .model_list then . else .model_list = [] end) |
    .model_list += [$model_obj] |
    (if .tools.web.duckduckgo then . else .tools.web.duckduckgo = {} end) |
    .tools.web.duckduckgo.enabled = $ddg' \
   "$CONFIG_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$CONFIG_FILE"

echo ""
echo "Installing FinOps Skill..."
SKILL_DIR="$HOME/.picoclaw/workspace/skills/finops"
mkdir -p "$SKILL_DIR"
if [ -f "$(dirname "$0")/SKILL.md" ]; then
    # When zipped together and run locally
    cp "$(dirname "$0")/SKILL.md" "$SKILL_DIR/SKILL.md"
elif [ -f "/opt/picoclaw/skills/finops/SKILL.md" ]; then
    # Fallback to the main repo path if running natively
    cp /opt/picoclaw/skills/finops/SKILL.md "$SKILL_DIR/SKILL.md"
else
    echo "Warning: Could not find SKILL.md to install."
fi
echo "FinOps SKILL.md installed to $SKILL_DIR/"

echo ""
echo "=================================================="
echo "Setup Complete! Starting the PicoClaw Linux Service"
echo "=================================================="
sudo systemctl enable picoclaw.service
sudo systemctl start picoclaw.service

echo ""
echo "The FinOps Copilot is now running in the background."
echo "View live logs with: sudo journalctl -u picoclaw -f"
echo "To interact with it via CLI, run: picoclaw agent -m \"Analyze my EC2 costs\""
