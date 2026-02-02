# OpenClaw AI 助手自动化部署套件

> 使用 Claude Code 对话式全自动部署 OpenClaw AI 助手到 VPS 服务器

**中文** | [English](README_EN.md)

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.6.0-green.svg)
![Platform](https://img.shields.io/badge/platform-Ubuntu%2022.04-orange.svg)
![Models](https://img.shields.io/badge/models-15-brightgreen.svg)
![Tools](https://img.shields.io/badge/tools-20%2B-blue.svg)

## 目录

- [包含内容](#包含内容)
- [快速开始](#快速开始)
- [系统要求](#系统要求)
- [部署后功能](#部署后功能)
- [使用示例](#使用示例)
- [推荐技能和扩展](#推荐技能和扩展)
- [文档结构](#文档结构)
- [常用命令](#常用命令)
- [故障排查](#故障排查)
- [安全建议](#安全建议)
- [常见问题](#常见问题)
- [相关资源](#相关资源)
- [贡献](#贡献)
- [作者](#作者)
- [许可证](#许可证)

## 📦 包含内容

**一键安装脚本** (`install-openclaw.sh`)
- 自动安装所有依赖
- 交互式/非交互式配置
- 自动启动服务
- 配置备份和恢复

## 快速开始

### 方式一：一键安装（推荐）

```bash
# 下载脚本
wget https://raw.githubusercontent.com/taielab/openclaw-autopilot/main/install-openclaw.sh

# 赋予执行权限
chmod +x install-openclaw.sh

# 运行安装
./install-openclaw.sh
```

### 方式二：非交互式安装

```bash
export TELEGRAM_BOT_TOKEN="your-bot-token"
export API_KEY="your-api-key"
# 可选：自定义网关配置
export GATEWAY_BIND="loopback"  # 或 0.0.0.0 开放公网
export GATEWAY_PORT="18789"
sudo -E ./install-openclaw.sh -n
```

### 方式三：更新模式

```bash
# 保留配置，仅升级 OpenClaw
sudo ./install-openclaw.sh -u
```

### 方式四：使用 Claude Code 对话式部署

1. 准备以下信息：
   - VPS 服务器 IP 和 SSH 凭据
   - Telegram Bot Token
   - AI API 密钥

2. 向 Claude Code 发送：
   ```
   我想在 VPS 上部署 OpenClaw AI 助手：
   - 服务器：<IP>
   - 用户：root
   - 密码：<password>
   - Telegram Bot Token：<token>
   - API：云雾 AI，Key：<api-key>
   
   请帮我完成全自动部署。
   ```

3. Claude Code 会自动完成所有部署步骤

## 系统要求

- **操作系统**: Ubuntu 22.04 LTS（推荐）
- **配置**: 最低 2 核 2GB 内存
- **网络**: 能访问国际网络
- **权限**: root 或 sudo 权限

## 部署后功能

### 核心功能
- 15 个顶流 AI 模型（GPT-5.2、Claude Opus 4.5、DeepSeek V3.2 等）
- Telegram Bot 交互界面
- 自动故障转移
- 浏览器自动化
- 多种技能和工具

### 已安装工具
- **AI/ML**: Whisper、yt-dlp、Pandas、NumPy
- **开发**: GitHub CLI、Git、Node.js、Python3
- **媒体**: FFmpeg、ImageMagick
- **系统**: jq、ripgrep、fd、bat、curl、wget

### 可用技能
- 🐙 GitHub 操作
- 🎞️ 视频处理
- 🌤️ 天气查询
- 🧵 tmux 控制
- 📦 技能创建

## 使用示例

### 与 AI 对话

在 Telegram 中找到你的 Bot，发送消息：

```
你好！帮我分析一下 https://github.com/openclaw/openclaw 这个项目
```

AI 会自动使用 GitHub CLI 工具获取仓库信息并进行分析。

### 切换 AI 模型

```
/model
```

Bot 会显示所有 15 个可用模型，选择你想使用的模型。

### 视频处理

```
帮我下载这个视频并提取关键帧：https://youtube.com/watch?v=xxxxx
```

AI 会使用 yt-dlp 和 FFmpeg 自动处理。

### 代码执行

```
用 Python 计算前 20 个斐波那契数列
```

AI 会编写并执行 Python 代码，返回结果。

### 网页抓取

```
帮我获取 https://example.com 的主要内容
```

AI 会使用浏览器自动化工具抓取网页内容。

## 🔌 推荐技能和扩展

OpenClaw 支持丰富的技能扩展，以下是社区推荐的优质技能：

### 国内通道集成
- **飞书集成**: clawdbot-feishu  
  https://github.com/m1heng/clawdbot-feishu
  
- **微信集成**: OpenClaw-Wechat  
  https://github.com/dingxiang-me/OpenClaw-Wechat
  
- **钉钉集成**: dingtalk-moltbot-connector  
  https://github.com/DingTalk-Real-AI/dingtalk-moltbot-connector
  
- **国内优化**: moltbot-china  
  https://github.com/BytePioneer-AI/moltbot-china

### 技能市场
- **Awesome Skills**: awesome-openclaw-skills  
  https://github.com/VoltAgent/awesome-openclaw-skills

> 💡 提示：安装技能后可大幅扩展 AI 助手的能力，支持更多场景和工作流。

## 文档结构

```
.
├── README.md                      # 本文件
└── install-openclaw.sh            # 一键安装脚本
```

## 常用命令

### 服务管理
```bash
# 查看服务状态
systemctl --user status openclaw-gateway

# 启动服务
systemctl --user start openclaw-gateway

# 停止服务
systemctl --user stop openclaw-gateway

# 重启服务
systemctl --user restart openclaw-gateway

# 查看日志
journalctl --user -u openclaw-gateway -f
```

### 配置管理
```bash
# 健康检查
openclaw doctor

# 查看技能
openclaw skills list

# 查看模型
openclaw models list

# 测试配置
openclaw gateway --port 18789
```

## 🐛 故障排查

### 服务无法启动

```bash
# 查看详细错误
openclaw gateway --port 18789

# 检查配置
openclaw doctor

# 查看日志
journalctl --user -u openclaw-gateway -n 50
```

### Telegram Bot 无响应

```bash
# 测试 Bot Token
curl https://api.telegram.org/bot<YOUR_TOKEN>/getMe

# 检查网络
curl https://api.telegram.org

# 查看 Gateway 日志
journalctl --user -u openclaw-gateway -f
```

### API 调用失败

```bash
# 测试 API 连接
curl -X POST https://yunwu.ai/v1/chat/completions \
  -H "Authorization: Bearer <YOUR_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-5.2","messages":[{"role":"user","content":"test"}]}'
```

## 🔐 安全建议

1. **限制访问**
   - 修改 `allowFrom` 只允许特定用户
   - 使用 `dmPolicy: "pairing"` 启用配对模式

2. **使用防火墙**
   ```bash
   ufw allow from 127.0.0.1 to any port 18789
   ```

3. **定期更新**
   ```bash
   npm update -g openclaw
   apt-get update && apt-get upgrade
   ```

4. **备份配置**
   ```bash
   tar -czf openclaw-backup-$(date +%Y%m%d).tar.gz ~/.openclaw
   ```

## ❓ 常见问题

### Q: 支持哪些 AI 模型？

A: 支持 15 个顶流模型：
- **OpenAI**: GPT-5.2, GPT-5.2 Codex
- **Anthropic**: Claude Opus 4.5, Claude Sonnet 4.5 (含 Thinking 版本)
- **DeepSeek**: DeepSeek V3.2 (含 Thinking 版本)
- **Google**: Gemini 3 Pro, Gemini 3 Pro Image
- **智谱**: GLM-4.7 (含 Thinking 版本)
- **MiniMax**: MiniMax M2.1
- **阿里**: Qwen3 Max
- **xAI**: Grok 4.1

### Q: 需要多少费用？

A: 主要费用包括：
- **VPS 服务器**: 约 $5-10/月（2核2GB配置）
- **API 调用**: 按使用量计费，使用云雾 AI 代理可降低成本
- **Telegram Bot**: 免费

### Q: 可以在本地电脑部署吗？

A: 可以，但需要：
- 保持电脑长期运行
- 配置端口转发（如果需要外网访问）
- 建议使用 VPS 以获得更好的稳定性

### Q: 如何添加更多模型？

A: 编辑 `~/.openclaw/openclaw.json`，在 `models.providers` 中添加新的 provider 配置，并在 `auth-profiles.json` 中添加对应的认证信息。详见完整教程。

### Q: 支持其他通道吗（如微信、Discord）？

A: OpenClaw 支持多种通道：
- Telegram（本教程配置）
- Discord
- Slack
- WhatsApp
- Signal
- iMessage

详见官方文档配置其他通道。

### Q: 如何更新 OpenClaw？

A: 运行以下命令：
```bash
npm update -g openclaw
systemctl --user restart openclaw-gateway
```

### Q: 遇到问题如何获取帮助？

A: 
2. 运行 `openclaw doctor` 进行健康检查
3. 查看日志 `journalctl --user -u openclaw-gateway -f`
4. 在 GitHub 提 Issue
5. 加入 Discord 社区求助

## 📖 相关资源

- **OpenClaw 官方文档**: https://docs.openclaw.ai
- **OpenClaw GitHub**: https://github.com/openclaw/openclaw
- **本项目 GitHub**: https://github.com/taielab/openclaw-autopilot
- **Discord 社区**: https://discord.gg/clawd
- **云雾 AI**: https://yunwu.ai/register?aff=PBpy （推荐 API 服务商）

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 如何贡献

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 贡献指南

- 提交前请确保代码通过测试
- 遵循现有代码风格
- 更新相关文档
- 在 PR 中详细描述更改内容

## 👨‍💻 作者

**AI 安全工坊**

关注我们获取更多 AI 技术干货：
- 微信公众号搜索：**AI安全工坊**
- X (Twitter)：https://x.com/JackW_AGI
- GitHub：https://github.com/taielab

## 📄 许可证

MIT License

## 👨‍💻 作者

AI 安全工坊

---

**祝你使用愉快！** 

如有问题，请查看完整教程或在 GitHub 提 Issue。


## 📝 更新日志

### v1.6.1 (2026-02-02)

**新增**
- 网关绑定自定义：loopback / 0.0.0.0 / 指定 IP
- 网关端口自定义
- 环境变量：`GATEWAY_BIND`、`GATEWAY_PORT`

### v1.6.0 (2026-02-02)

**🚀 脚本功能**
- 非交互模式 (`-n`) + 环境变量支持
- 更新模式 (`-u`) 保留配置升级
- 配置备份 + DELETE 确认机制
- Telegram 白名单配置
- CLI 自动补全安装

**⚙️ 配置优化 (93% 覆盖率)**
- Agent: timeout(300s), mediaMax(20MB), thinking(low), compaction
- Session: reset(daily/3am), dmScope(per-channel-peer), typingMode
- Telegram: streamMode(partial), groupPolicy(allowlist)
- System: env, cron, web, canvasHost, logging, diagnostics

**🔐 安全增强**
- 白名单模式自动设置 dmPolicy=pairing
- 配置文件权限 chmod 600
- 会话隔离 per-channel-peer

### v1.0.0 (2026-01-29)
- 初始版本发布
