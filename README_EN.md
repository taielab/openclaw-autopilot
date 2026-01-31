# OpenClaw AI Assistant Automated Deployment Kit

> Conversational deployment of OpenClaw AI assistant to VPS server using Claude Code

[中文](README.md) | **English**

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)
![Platform](https://img.shields.io/badge/platform-Ubuntu%2022.04-orange.svg)
![Models](https://img.shields.io/badge/models-15-brightgreen.svg)
![Tools](https://img.shields.io/badge/tools-20%2B-blue.svg)

## Table of Contents

- [What's Included](#whats-included)
- [Quick Start](#quick-start)
- [System Requirements](#system-requirements)
- [Features After Deployment](#features-after-deployment)
- [Usage Examples](#usage-examples)
- [Recommended Skills and Extensions](#recommended-skills-and-extensions)
- [Documentation Structure](#documentation-structure)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)
- [Security Recommendations](#security-recommendations)
- [FAQ](#faq)
- [Resources](#resources)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

## 📦 What's Included

1. **Complete Deployment Tutorial** (`OpenClaw自动化部署教程.md`)
   - Step-by-step guide
   - Configuration instructions
   - Troubleshooting
   - Advanced configuration

2. **One-Click Installation Script** (`install-openclaw.sh`)
   - Auto-install all dependencies
   - Interactive configuration
   - Auto-start service

## Quick Start

### Method 1: One-Click Installation (Recommended)

```bash
# Download script
wget https://raw.githubusercontent.com/taielab/openclaw-autopilot/main/install-openclaw.sh

# Make executable
chmod +x install-openclaw.sh

# Run installation
./install-openclaw.sh
```

### Method 2: Conversational Deployment with Claude Code

1. Prepare the following information:
   - VPS server IP and SSH credentials
   - Telegram Bot Token
   - AI API key

2. Send to Claude Code:
   ```
   I want to deploy OpenClaw AI assistant on VPS:
   - Server: <IP>
   - User: root
   - Password: <password>
   - Telegram Bot Token: <token>
   - API: Yunwu AI, Key: <api-key>
   
   Please help me complete the automated deployment.
   ```

3. Claude Code will automatically complete all deployment steps

## System Requirements

- **OS**: Ubuntu 22.04 LTS (recommended)
- **Specs**: Minimum 2 cores, 2GB RAM
- **Network**: International network access
- **Permissions**: root or sudo access

## Features After Deployment

### Core Features
- 15 top-tier AI models (GPT-5.2, Claude Opus 4.5, DeepSeek V3.2, etc.)
- Telegram Bot interface
- Automatic failover
- Browser automation
- Multiple skills and tools

### Installed Tools
- **AI/ML**: Whisper, yt-dlp, Pandas, NumPy
- **Development**: GitHub CLI, Git, Node.js, Python3
- **Media**: FFmpeg, ImageMagick
- **System**: jq, ripgrep, fd, bat, curl, wget

### Available Skills
- 🐙 GitHub operations
- 🎞️ Video processing
- 🌤️ Weather queries
- 🧵 tmux control
- 📦 Skill creation

## Usage Examples

### Chat with AI

Find your Bot on Telegram and send a message:

```
Hello! Help me analyze this project: https://github.com/openclaw/openclaw
```

AI will automatically use GitHub CLI tools to fetch repository information and analyze it.

### Switch AI Models

```
/model
```

Bot will display all 15 available models for you to choose from.

### Video Processing

```
Download this video and extract key frames: https://youtube.com/watch?v=xxxxx
```

AI will use yt-dlp and FFmpeg to process automatically.

### Code Execution

```
Calculate the first 20 Fibonacci numbers using Python
```

AI will write and execute Python code, returning the results.

### Web Scraping

```
Get the main content from https://example.com
```

AI will use browser automation tools to scrape web content.

## 🔌 Recommended Skills and Extensions

OpenClaw supports rich skill extensions. Here are community-recommended quality skills:

### China Channel Integration
- **Feishu Integration**: clawdbot-feishu  
  https://github.com/m1heng/clawdbot-feishu
  
- **WeChat Integration**: OpenClaw-Wechat  
  https://github.com/dingxiang-me/OpenClaw-Wechat
  
- **DingTalk Integration**: dingtalk-moltbot-connector  
  https://github.com/DingTalk-Real-AI/dingtalk-moltbot-connector
  
- **China Optimization**: moltbot-china  
  https://github.com/BytePioneer-AI/moltbot-china

### Skill Marketplace
- **Awesome Skills**: awesome-openclaw-skills  
  https://github.com/VoltAgent/awesome-openclaw-skills

> 💡 Tip: Installing skills can greatly expand your AI assistant's capabilities, supporting more scenarios and workflows.

## Documentation Structure

```
.
├── README.md                      # Chinese version
├── README_EN.md                   # English version (this file)
└── install-openclaw.sh            # One-click installation script
```

## Common Commands

### Service Management
```bash
# Check service status
systemctl --user status openclaw-gateway

# Start service
systemctl --user start openclaw-gateway

# Stop service
systemctl --user stop openclaw-gateway

# Restart service
systemctl --user restart openclaw-gateway

# View logs
journalctl --user -u openclaw-gateway -f
```

### Configuration Management
```bash
# Health check
openclaw doctor

# List skills
openclaw skills list

# List models
openclaw models list

# Test configuration
openclaw gateway --port 18789
```

## 🐛 Troubleshooting

### Service Won't Start

```bash
# View detailed errors
openclaw gateway --port 18789

# Check configuration
openclaw doctor

# View logs
journalctl --user -u openclaw-gateway -n 50
```

### Telegram Bot Not Responding

```bash
# Test Bot Token
curl https://api.telegram.org/bot<YOUR_TOKEN>/getMe

# Check network
curl https://api.telegram.org

# View Gateway logs
journalctl --user -u openclaw-gateway -f
```

### API Call Failures

```bash
# Test API connection
curl -X POST https://yunwu.ai/v1/chat/completions \
  -H "Authorization: Bearer <YOUR_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-5.2","messages":[{"role":"user","content":"test"}]}'
```

## 🔐 Security Recommendations

1. **Restrict Access**
   - Modify `allowFrom` to allow only specific users
   - Use `dmPolicy: "pairing"` to enable pairing mode

2. **Use Firewall**
   ```bash
   ufw allow from 127.0.0.1 to any port 18789
   ```

3. **Regular Updates**
   ```bash
   npm update -g openclaw
   apt-get update && apt-get upgrade
   ```

4. **Backup Configuration**
   ```bash
   tar -czf openclaw-backup-$(date +%Y%m%d).tar.gz ~/.openclaw
   ```

## ❓ FAQ

### Q: Which AI models are supported?

A: 15 top-tier models:
- **OpenAI**: GPT-5.2, GPT-5.2 Codex
- **Anthropic**: Claude Opus 4.5, Claude Sonnet 4.5 (with Thinking versions)
- **DeepSeek**: DeepSeek V3.2 (with Thinking version)
- **Google**: Gemini 3 Pro, Gemini 3 Pro Image
- **Zhipu**: GLM-4.7 (with Thinking version)
- **MiniMax**: MiniMax M2.1
- **Alibaba**: Qwen3 Max
- **xAI**: Grok 4.1

### Q: How much does it cost?

A: Main costs include:
- **VPS Server**: ~$5-10/month (2 cores, 2GB RAM)
- **API Calls**: Pay-as-you-go, using Yunwu AI proxy can reduce costs
- **Telegram Bot**: Free

### Q: Can I deploy on my local computer?

A: Yes, but you need to:
- Keep your computer running 24/7
- Configure port forwarding (if external access needed)
- VPS is recommended for better stability

### Q: How to add more models?

A: Edit `~/.openclaw/openclaw.json`, add new provider configuration in `models.providers`, and add corresponding authentication in `auth-profiles.json`. See complete tutorial for details.

### Q: Does it support other channels (WeChat, Discord)?

A: OpenClaw supports multiple channels:
- Telegram (configured in this tutorial)
- Discord
- Slack
- WhatsApp
- Signal
- iMessage

See official documentation for configuring other channels.

### Q: How to update OpenClaw?

A: Run the following commands:
```bash
npm update -g openclaw
systemctl --user restart openclaw-gateway
```

### Q: How to get help when encountering issues?

A: 
1. Check complete tutorial `OpenClaw自动化部署教程.md`
2. Run `openclaw doctor` for health check
3. View logs `journalctl --user -u openclaw-gateway -f`
4. Submit an Issue on GitHub
5. Join Discord community for help

## 📖 Resources

- **OpenClaw Official Docs**: https://docs.openclaw.ai
- **OpenClaw GitHub**: https://github.com/openclaw/openclaw
- **This Project GitHub**: https://github.com/taielab/openclaw-autopilot
- **Discord Community**: https://discord.gg/clawd
- **Yunwu AI**: https://yunwu.ai/register?aff=PBpy (Recommended API Provider)

## 🤝 Contributing

Issues and Pull Requests are welcome!

### How to Contribute

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contribution Guidelines

- Ensure code passes tests before submitting
- Follow existing code style
- Update relevant documentation
- Describe changes in detail in PR

## 👨‍💻 Author

**AI Security Workshop**

Follow us for more AI tech content:
- WeChat Official Account: **AI安全工坊**
- X (Twitter): https://x.com/JackW_AGI
- GitHub: https://github.com/taielab

## 📄 License

MIT License

---

**Enjoy!** 

If you have any questions, please check the complete tutorial or submit an issue on GitHub.
