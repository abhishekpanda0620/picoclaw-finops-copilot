# Slack Integration Setup

The PicoClaw FinOps Copilot communicates natively through Slack, allowing your entire engineering team to interrogate AWS costs interactively.

Here is how to set up the connection.

## 1. Create a Slack App
1. Go to the [Slack API Dashboard](https://api.slack.com/apps).
2. Click **Create New App** -> **From scratch**.
3. Name it "PicoClaw FinOps" (or similar) and select your workspace.

## 2. Enable Socket Mode
Because PicoClaw runs on an internal EC2 instance without a public webhook endpoint, it uses Socket Mode to establish a WebSocket connection to Slack.
1. In the left sidebar, navigate to **Socket Mode**.
2. Toggle **Enable Socket Mode** to **On**.
3. You will be prompted to generate an App-Level Token. Name it `picoclaw-socket` and click **Generate**.
4. Save the token starting with `xapp-` securely. You will need this for the PicoClaw configuration.

## 3. Configure OAuth & Permissions
1. In the left sidebar, navigate to **OAuth & Permissions**.
2. Scroll down to **Scopes** -> **Bot Token Scopes** and add the following:
   - `app_mentions:read` (Required to respond when someone tags `@PicoClaw`)
   - `chat:write` (Required to send messages back to the channel)
   - `channels:history` (Required for context if conversing in a public channel)
   - `im:history` (Required for direct messaging)

## 4. Install the App
1. At the top of the **OAuth & Permissions** page, click **Install to Workspace**.
2. After authorizing, you will receive a **Bot User OAuth Token**. 
3. Save the token starting with `xoxb-` securely.

## 5. Enable Event Subscriptions
1. In the left sidebar, navigate to **Event Subscriptions**.
2. Toggle **Enable Events** to **On**.
3. (Since you are using Socket Mode, you do not need to provide a Request URL).
4. Expand **Subscribe to bot events** and add:
   - `app_mention`
   - `message.im`
5. Click **Save Changes** at the bottom of the page.

## 6. Configure PicoClaw
Update the PicoClaw configuration file (`~/.picoclaw/config.json`) on your EC2 instance to include the Slack tokens:

```json
{
  "channels": {
    "slack": {
      "enabled": true,
      "bot_token": "xoxb-YOUR-BOT-TOKEN",
      "app_token": "xapp-YOUR-APP-TOKEN",
      "allow_from": [] 
    }
  }
}
```

Restart the PicoClaw service for the changes to take effect:
```bash
sudo systemctl restart picoclaw
```

Now, invite your bot to a channel (e.g., `#finops`) by mentioning it (`@PicoClaw FinOps`), and you're ready to start asking about AWS costs!
