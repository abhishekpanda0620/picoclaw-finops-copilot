# Automation & Scheduled Reports

One of the most powerful features of the PicoClaw FinOps Copilot is its ability to run the FinOps Skills autonomously on a schedule and push the results directly to your Slack channel.

## How it Works
PicoClaw uses a native "Heartbeat" mechanism. Every 30 minutes (configurable), PicoClaw reads a special file called `HEARTBEAT.md` inside its workspace. If tasks are defined in that file, PicoClaw will execute them automatically.

## 1. Enable Heartbeat
First, ensure that the heartbeat is enabled in your `~/.picoclaw/config.json`:

```json
{
  "heartbeat": {
    "enabled": true,
    "interval": 30
  }
}
```
*(interval is in minutes)*

## 2. Define the Automation Tasks
Create or edit the `HEARTBEAT.md` file in the agent's workspace (`~/.picoclaw/workspace/HEARTBEAT.md`).

You can use the `spawn` tool syntax to run AWS Cost analysis entirely in the background and proactively direct-message the results to a Slack channel.

### Example: Daily Cost Summary

```markdown
# Periodic FinOps Tasks

## Long Tasks (use spawn for async)

- Query AWS for a cost summary covering the last 2 days. Then send a message with the formatted results directly to the #finops-alerts Slack channel. Highlight any sudden spikes.
- Check for unused or available EBS volumes. If you find any, calculate the monthly waste and post a warning message in the #finops-alerts Slack channel.
```

## 3. Scheduled Crons (Alternative)
If you require strict scheduled timing (e.g., exactly at 9:00 AM every Monday) rather than interval-based heartbeats, you can combine PicoClaw's CLI with standard Linux cron jobs on the EC2 instance.

Edit the crontab:
```bash
crontab -e
```

**Example: Send a weekly executive summary every Monday at 9 AM:**
```bash
0 9 * * 1 /usr/local/bin/picoclaw agent -m "Calculate the top 5 AWS services cost from the last 7 days and post an Executive Summary to the #leadership-updates Slack channel."
```
