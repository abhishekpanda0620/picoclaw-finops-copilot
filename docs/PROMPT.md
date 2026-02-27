# FinOps Copilot Prompts

This document outlines example prompts and questions you can ask the PicoClaw FinOps Copilot via Slack, Telegram, or the local CLI.

Because PicoClaw is powered by an LLM, you don't need to memorize exact syntax. However, the queries below are highly optimized to trigger specific AWS Cost Explorer and optimization tracking logic.

## 💰 Cost Tracking & Summaries

**General Spend:**
* *"What did we spend on AWS yesterday?"*
* *"Show me the top 5 most expensive AWS services for the last 7 days."*
* *"What is our total AWS cost for this month so far?"*

**Monthly Comparisons:**
* *"Compare our AWS costs from this month vs last month."*
* *"Are there any services where our spending increased significantly compared to last month?"*

**S3 Storage Visibility:**
* *"What are our top S3 storage costs for the last week?"*
* *"Show me the AWS S3 spend breakdown."*

## ⚠️ Waste & Optimization Detection

PicoClaw is highly effective at identifying stranded or idle infrastructure that incurs hourly charges.

**Idle EBS Volumes:**
* *"Do we have any unused or unattached EBS volumes?"*
* *"Scan for idle EBS volumes and calculate the monthly waste."*

**Idle Load Balancers:**
* *"Are there any idle Application Load Balancers (ALBs) with zero traffic?"*
* *"Find any ELBs without healthy targets attached."*

**Unused Elastic IPs:**
* *"Do we have any Elastic IPs (EIPs) allocated but not attached to an instance?"*
* *"Calculate the waste from unattached EIPs."*

## 🤖 Deep Dives & General Explanations

Because PicoClaw has general LLM reasoning capabilities, you can also ask it to explain FinOps concepts.

* *"Explain the difference between S3 Standard and S3 Intelligent-Tiering."*
* *"What is the difference between Amortized Costs and Blended Costs in AWS?"*
* *"How much do idle Network Interfaces (ENIs) cost?"*

## ⚙️ Automation

You can configure PicoClaw to run these prompts automatically on a schedule (e.g. daily standup reports). See the `docs/automation.md` for information on using `HEARTBEAT.md` internally, or standard Linux `cron` jobs, to push these reports directly into your Slack or Telegram channels.
