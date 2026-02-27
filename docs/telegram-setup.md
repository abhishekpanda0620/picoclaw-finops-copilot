# Telegram Integration Setup

PicoClaw FinOps Copilot can communicate securely through Telegram, providing a mobile-friendly alternative to Slack for querying AWS costs and receiving automated FinOps alerts.

## 1. Create a Telegram Bot
1. Open the Telegram app and search for the **BotFather** (`@BotFather`, verify the blue checkmark).
2. Send the `/newbot` command.
3. Choose a display name for your FinOps bot (e.g., "Company FinOps Copilot").
4. Choose a unique username ending in `bot` (e.g., `acme_finops_bot`).
5. **BotFather** will generate an **HTTP API Token**. Save this string securely. It will look something like `123456789:ABCdefGHIjklmNOPqrstUVWxyz`.

## 2. Secure Your Bot
Because financial data is sensitive, you **must restrict** who can talk to your bot. PicoClaw supports whitelisting Telegram User IDs.

To find your Telegram User ID:
1. Search for the `@userinfobot` in Telegram or a similar ID bot.
2. Send the `/start` command.
3. It will reply with your numeric `Id` (e.g., `987654321`).
4. Collect the IDs of any DevOps/FinOps team members who need access.

## 3. Configure PicoClaw
Update the PicoClaw configuration file (`~/.picoclaw/config.json`) on your EC2 instance to include the Telegram tokens and the allowed User IDs.

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "bot_token": "YOUR_TELEGRAM_HTTP_API_TOKEN",
      "allow_from": ["987654321", "123456789"] 
    }
  }
}
```
*(Replace the strings in the array with your actual authorized User IDs)*

## 4. Restart the Service
Restart the PicoClaw service for the changes to take effect:
```bash
sudo systemctl restart picoclaw
```

## 5. Usage
Find your bot in Telegram using the `@username` you created in step 1. Send it a message like:
> "Calculate my top 5 AWS services by cost for the last 7 days."

Only users listed in the `allow_from` array will receive AWS intelligence. Other users will be ignored or denied access.
