#!/bin/bash

#############################################
# OpenClaw AI 助手一键安装脚本
# 适用于 Ubuntu 22.04 LTS
# 作者：AI 安全工坊
# 版本：1.6.0
# OpenClaw 版本：v2026.1.30
#############################################

set -e

# 全局变量
NON_INTERACTIVE=false
UPDATE_MODE=false
SCENARIO="personal"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助
show_help() {
    cat << EOF
OpenClaw AI 助手一键安装脚本 v1.6.0

用法: $0 [选项]

选项:
  -h, --help          显示帮助信息
  -n, --non-interactive  非交互模式（需要设置环境变量）
  -u, --update        更新模式（保留现有配置）
  -s, --scenario      使用场景: personal(默认), team, dev

环境变量（非交互模式必需）:
  TELEGRAM_BOT_TOKEN  Telegram Bot Token
  API_KEY             API Key（云雾 AI 或其他）
  API_BASE_URL        API Base URL（默认: https://yunwu.ai）
  TELEGRAM_DM_POLICY  DM 策略: pairing(默认) 或 open
  TELEGRAM_ALLOW_FROM 白名单 JSON 数组（默认: ["*"]）
  EXEC_APPROVAL       命令审批: true(默认) 或 false

示例:
  # 交互式安装
  $0

  # 非交互式安装
  TELEGRAM_BOT_TOKEN="xxx" API_KEY="xxx" $0 -n

  # 指定白名单
  TELEGRAM_BOT_TOKEN="xxx" API_KEY="xxx" TELEGRAM_ALLOW_FROM='["123456","789012"]' $0 -n

  # 更新模式
  $0 -u
EOF
    exit 0
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -n|--non-interactive)
                NON_INTERACTIVE=true
                shift
                ;;
            -u|--update)
                UPDATE_MODE=true
                shift
                ;;
            -s|--scenario)
                SCENARIO="$2"
                shift 2
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                ;;
        esac
    done
}

# 检查是否为 root 用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 root 用户运行此脚本"
        exit 1
    fi
}

# 检查系统版本
check_system() {
    log_info "检查系统版本..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        log_error "无法检测系统版本"
        exit 1
    fi
    
    if [[ "$OS" != "Ubuntu" ]] || [[ "$VER" != "22.04" ]]; then
        log_warning "推荐使用 Ubuntu 22.04 LTS，当前系统：$OS $VER"
        if [ "$NON_INTERACTIVE" = false ]; then
            read -p "是否继续？(y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
    
    log_success "系统检查通过"
}

# 检查时区
check_timezone() {
    log_info "检查时区设置..."
    CURRENT_TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "unknown")
    log_info "当前时区: $CURRENT_TZ"
    
    if [[ "$CURRENT_TZ" == "Etc/UTC" ]] || [[ "$CURRENT_TZ" == "UTC" ]]; then
        log_warning "建议设置本地时区以便会话重置时间准确"
        log_info "可使用: timedatectl set-timezone Asia/Shanghai"
    fi
}

# 检查防火墙
check_firewall() {
    log_info "检查防火墙状态..."
    
    if command -v ufw &> /dev/null; then
        UFW_STATUS=$(ufw status | head -1)
        if [[ "$UFW_STATUS" == *"active"* ]]; then
            log_warning "UFW 防火墙已启用"
            log_info "OpenClaw Gateway 默认绑定 loopback，无需开放端口"
        fi
    fi
}

# 备份现有配置
backup_config() {
    if [ -f ~/.openclaw/openclaw.json ]; then
        BACKUP_DIR=~/.openclaw/backup-$(date +%Y%m%d-%H%M%S)
        log_info "备份现有配置到: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp -r ~/.openclaw/openclaw.json "$BACKUP_DIR/" 2>/dev/null || true
        cp -r ~/.openclaw/agents "$BACKUP_DIR/" 2>/dev/null || true
        cp -r ~/.openclaw/credentials "$BACKUP_DIR/" 2>/dev/null || true
        log_success "配置已备份"
    fi
}

# 收集配置信息
collect_config() {
    # 检查是否已有配置（更新模式）
    if [ "$UPDATE_MODE" = true ] && [ -f ~/.openclaw/openclaw.json ]; then
        log_info "更新模式：保留现有配置"
        return
    fi
    
    # 检查是否需要重装确认
    if [ -f ~/.openclaw/openclaw.json ] && [ "$NON_INTERACTIVE" = false ]; then
        log_warning "检测到已有配置"
        echo
        echo "选择操作："
        echo "1) 更新 OpenClaw（保留配置）"
        echo "2) 完全重装（删除配置）"
        read -p "请选择 (1-2): " INSTALL_CHOICE
        
        if [ "$INSTALL_CHOICE" = "1" ]; then
            UPDATE_MODE=true
            return
        elif [ "$INSTALL_CHOICE" = "2" ]; then
            log_error "⚠️  危险操作：完全重装将删除所有配置！"
            echo
            read -p "确认删除？请输入 'DELETE' 确认: " CONFIRM_DELETE
            if [ "$CONFIRM_DELETE" = "DELETE" ]; then
                backup_config
                rm -rf ~/.openclaw/openclaw.json ~/.openclaw/agents ~/.openclaw/sessions
                log_success "配置已清除（备份已保留）"
            else
                log_info "已取消重装操作"
                exit 0
            fi
        fi
    fi

    # 非交互模式：从环境变量读取
    if [ "$NON_INTERACTIVE" = true ]; then
        if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$API_KEY" ]; then
            log_error "非交互模式需要设置 TELEGRAM_BOT_TOKEN 和 API_KEY 环境变量"
            exit 1
        fi
        API_BASE_URL="${API_BASE_URL:-https://yunwu.ai}"
        TELEGRAM_DM_POLICY="${TELEGRAM_DM_POLICY:-pairing}"
        TELEGRAM_ALLOW_FROM="${TELEGRAM_ALLOW_FROM:-[\"*\"]}"
        EXEC_APPROVAL="${EXEC_APPROVAL:-true}"
        return
    fi

    log_info "请输入配置信息..."
    echo
    
    # Telegram Bot Token
    read -p "请输入 Telegram Bot Token: " TELEGRAM_BOT_TOKEN
    if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
        log_error "Telegram Bot Token 不能为空"
        exit 1
    fi
    
    # API 服务商选择
    echo
    echo "请选择 API 服务商："
    echo "1) 云雾 AI (推荐，一个 Key 访问所有模型)"
    echo "2) 自定义 API 端点"
    read -p "请选择 (1-2): " API_CHOICE
    
    case $API_CHOICE in
        1)
            API_BASE_URL="https://yunwu.ai"
            ;;
        2)
            read -p "请输入 API Base URL: " API_BASE_URL
            ;;
        *)
            log_error "无效的选择"
            exit 1
            ;;
    esac
    
    # API Key
    read -p "请输入 API Key: " API_KEY
    if [ -z "$API_KEY" ]; then
        log_error "API Key 不能为空"
        exit 1
    fi

    # DM 策略
    # 白名单设置
    echo
    echo "请设置 Telegram 白名单："
    echo "1) 允许所有人 (*)"
    echo "2) 指定用户 ID（多个用逗号分隔）"
    read -p "请选择 (1-2): " ALLOWLIST_CHOICE
    if [ "$ALLOWLIST_CHOICE" = "2" ]; then
        read -p "请输入允许的用户 ID（逗号分隔）: " ALLOW_IDS
        # 转换为 JSON 数组格式
        TELEGRAM_ALLOW_FROM=$(echo "$ALLOW_IDS" | sed 's/,/","/g' | sed 's/^/["/;s/$/"]/')
        # 白名单模式必须使用 pairing 策略
        TELEGRAM_DM_POLICY="pairing"
        log_info "已自动设置 DM 策略为 pairing（白名单模式要求）"
    else
        TELEGRAM_ALLOW_FROM='["*"]'
        # 允许所有人时询问 DM 策略
        echo
        echo "请选择 DM 策略："
        echo "1) pairing (推荐，需要配对码验证)"
        echo "2) open (允许所有人直接访问)"
        read -p "请选择 (1-2): " DM_CHOICE
        TELEGRAM_DM_POLICY=$([[ "$DM_CHOICE" = "2" ]] && echo "open" || echo "pairing")
    fi

    # 命令审批
    echo
    read -p "是否启用命令执行审批？(Y/n): " APPROVAL_CHOICE
    EXEC_APPROVAL=$([[ "$APPROVAL_CHOICE" =~ ^[Nn]$ ]] && echo "false" || echo "true")
    
    echo
    log_success "配置信息收集完成"
}

# 安装 Node.js
install_nodejs() {
    log_info "安装 Node.js 22..."
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -ge 22 ]; then
            log_success "Node.js 已安装 ($(node -v))"
            return
        else
            log_warning "Node.js 版本过低 ($(node -v))，需要 >= 22"
        fi
    fi
    
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
    
    # 验证安装
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 22 ]; then
        log_error "Node.js 安装失败，版本不满足要求"
        exit 1
    fi
    
    log_success "Node.js 安装完成 ($(node -v))"
}

# 安装 OpenClaw
install_openclaw() {
    log_info "安装 OpenClaw..."
    
    if [ "$UPDATE_MODE" = true ]; then
        log_info "更新模式：升级 OpenClaw"
    fi
    
    npm install -g openclaw@latest
    
    OPENCLAW_VERSION=$(openclaw --version 2>&1 | head -1 || echo "unknown")
    log_success "OpenClaw 安装完成 ($OPENCLAW_VERSION)"
    
    # 安装 CLI 自动补全
    log_info "安装 CLI 自动补全..."
    openclaw completion install 2>/dev/null || log_warning "自动补全安装跳过"
}

# 配置 OpenClaw
configure_openclaw() {
    log_info "配置 OpenClaw（生产环境配置：15个顶流模型）..."
    
    # 创建配置目录
    mkdir -p ~/.openclaw/agents/main/agent
    mkdir -p ~/.openclaw/workspace
    
    # 生成认证 Token
    AUTH_TOKEN=$(openssl rand -hex 32)
    
    # 创建主配置文件（与生产环境一致）
    cat > ~/.openclaw/openclaw.json << EOF
{
  "agents": {
    "defaults": {
      "workspace": "~/.openclaw/workspace",
      "models": {
        "api-proxy-gpt/gpt-5.2": { "alias": "GPT-5.2" },
        "api-proxy-gpt/gpt-5.2-codex": { "alias": "GPT-5.2 Codex" },
        "api-proxy-claude/claude-opus-4-5-20251101": { "alias": "Claude Opus 4.5" },
        "api-proxy-claude/claude-opus-4-5-20251101-thinking": { "alias": "Claude Opus 4.5 Thinking" },
        "api-proxy-claude/claude-sonnet-4-5-20250929": { "alias": "Claude Sonnet 4.5" },
        "api-proxy-claude/claude-sonnet-4-5-20250929-thinking": { "alias": "Claude Sonnet 4.5 Thinking" },
        "api-proxy-deepseek/deepseek-v3.2": { "alias": "DeepSeek V3.2" },
        "api-proxy-deepseek/deepseek-v3.2-thinking": { "alias": "DeepSeek V3.2 Thinking" },
        "api-proxy-google/gemini-3-pro-preview": { "alias": "Gemini 3 Pro" },
        "api-proxy-google/gemini-3-pro-image-preview": { "alias": "Gemini 3 Pro Image" },
        "api-proxy-glm/glm-4.7": { "alias": "GLM-4.7" },
        "api-proxy-glm/glm-4.7-thinking": { "alias": "GLM-4.7 Thinking" },
        "api-proxy-minimax/minimax-m2.1": { "alias": "MiniMax M2.1" },
        "api-proxy-qwen/qwen3-max-2026-01-23": { "alias": "Qwen3 Max" },
        "api-proxy-xai/grok-4.1": { "alias": "Grok 4.1" }
      },
      "model": {
        "primary": "api-proxy-gpt/gpt-5.2",
        "fallbacks": [
          "api-proxy-claude/claude-opus-4-5-20251101",
          "api-proxy-deepseek/deepseek-v3.2"
        ]
      },
      "timeoutSeconds": 300,
      "mediaMaxMb": 20,
      "maxConcurrent": 12,
      "thinkingDefault": "low",
      "userTimezone": "Asia/Shanghai",
      "envelopeTimestamp": "on",
      "compaction": {
        "mode": "safeguard",
        "reserveTokensFloor": 10000,
        "maxHistoryShare": 0.7
      },
      "subagents": {
        "maxConcurrent": 24
      }
    }
  },
  "auth": {
    "profiles": {
      "api-proxy-gpt:default": { "provider": "api-proxy-gpt", "mode": "api_key" },
      "api-proxy-claude:default": { "provider": "api-proxy-claude", "mode": "api_key" },
      "api-proxy-deepseek:default": { "provider": "api-proxy-deepseek", "mode": "api_key" },
      "api-proxy-google:default": { "provider": "api-proxy-google", "mode": "api_key" },
      "api-proxy-glm:default": { "provider": "api-proxy-glm", "mode": "api_key" },
      "api-proxy-minimax:default": { "provider": "api-proxy-minimax", "mode": "api_key" },
      "api-proxy-qwen:default": { "provider": "api-proxy-qwen", "mode": "api_key" },
      "api-proxy-xai:default": { "provider": "api-proxy-xai", "mode": "api_key" }
    }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "api-proxy-gpt": {
        "baseUrl": "${API_BASE_URL}/v1",
        "api": "openai-completions",
        "models": [
          { "id": "gpt-5.2", "name": "GPT-5.2", "contextWindow": 200000, "maxTokens": 16384 },
          { "id": "gpt-5.2-codex", "name": "GPT-5.2 Codex", "contextWindow": 200000, "maxTokens": 16384 }
        ]
      },
      "api-proxy-claude": {
        "baseUrl": "${API_BASE_URL}",
        "api": "anthropic-messages",
        "models": [
          { "id": "claude-opus-4-5-20251101", "name": "Claude Opus 4.5", "contextWindow": 200000, "maxTokens": 8192 },
          { "id": "claude-opus-4-5-20251101-thinking", "name": "Claude Opus 4.5 Thinking", "contextWindow": 200000, "maxTokens": 8192 },
          { "id": "claude-sonnet-4-5-20250929", "name": "Claude Sonnet 4.5", "contextWindow": 200000, "maxTokens": 8192 },
          { "id": "claude-sonnet-4-5-20250929-thinking", "name": "Claude Sonnet 4.5 Thinking", "contextWindow": 200000, "maxTokens": 8192 }
        ]
      },
      "api-proxy-deepseek": {
        "baseUrl": "${API_BASE_URL}/v1",
        "api": "openai-completions",
        "models": [
          { "id": "deepseek-v3.2", "name": "DeepSeek V3.2", "contextWindow": 64000, "maxTokens": 8192 },
          { "id": "deepseek-v3.2-thinking", "name": "DeepSeek V3.2 Thinking", "contextWindow": 64000, "maxTokens": 8192 }
        ]
      },
      "api-proxy-google": {
        "baseUrl": "${API_BASE_URL}",
        "api": "google-generative-ai",
        "models": [
          { "id": "gemini-3-pro-preview", "name": "Gemini 3 Pro", "contextWindow": 2000000, "maxTokens": 8192 },
          { "id": "gemini-3-pro-image-preview", "name": "Gemini 3 Pro Image", "contextWindow": 2000000, "maxTokens": 8192 }
        ]
      },
      "api-proxy-glm": {
        "baseUrl": "${API_BASE_URL}/v1",
        "api": "openai-completions",
        "models": [
          { "id": "glm-4.7", "name": "GLM-4.7", "contextWindow": 128000, "maxTokens": 8192 },
          { "id": "glm-4.7-thinking", "name": "GLM-4.7 Thinking", "contextWindow": 128000, "maxTokens": 8192 }
        ]
      },
      "api-proxy-minimax": {
        "baseUrl": "${API_BASE_URL}/v1",
        "api": "openai-completions",
        "models": [
          { "id": "minimax-m2.1", "name": "MiniMax M2.1", "contextWindow": 128000, "maxTokens": 8192 }
        ]
      },
      "api-proxy-qwen": {
        "baseUrl": "${API_BASE_URL}/v1",
        "api": "openai-completions",
        "models": [
          { "id": "qwen3-max-2026-01-23", "name": "Qwen3 Max", "contextWindow": 128000, "maxTokens": 8192 }
        ]
      },
      "api-proxy-xai": {
        "baseUrl": "${API_BASE_URL}/v1",
        "api": "openai-completions",
        "models": [
          { "id": "grok-4.1", "name": "Grok 4.1", "contextWindow": 128000, "maxTokens": 8192 }
        ]
      }
    }
  },
  "browser": {
    "enabled": true,
    "executablePath": "/usr/bin/chromium-browser",
    "headless": true
  },
  "channels": {
    "telegram": {
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "allowFrom": ${TELEGRAM_ALLOW_FROM},
      "dmPolicy": "${TELEGRAM_DM_POLICY}",
      "groupPolicy": "allowlist",
      "streamMode": "partial"
    }
  },
  "approvals": {
    "exec": {
      "enabled": ${EXEC_APPROVAL}
    }
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto"
  },
  "messages": {
    "ackReactionScope": "group-mentions"
  },
  "session": {
    "scope": "per-sender",
    "dmScope": "per-channel-peer",
    "idleMinutes": 30,
    "reset": {
      "mode": "daily",
      "atHour": 3
    },
    "typingMode": "thinking",
    "typingIntervalSeconds": 3
  },
  "env": {
    "shellEnv": {
      "enabled": true,
      "timeoutMs": 5000
    }
  },
  "cron": {
    "enabled": true,
    "maxConcurrentRuns": 5
  },
  "media": {
    "preserveFilenames": true
  },
  "ui": {
    "assistant": {
      "name": "OpenClaw AI",
      "avatar": "🤖"
    }
  },
  "web": {
    "enabled": true
  },
  "canvasHost": {
    "enabled": true
  },
  "discovery": {
    "mdns": {
      "mode": "minimal"
    }
  },
  "broadcast": {
    "strategy": "parallel"
  },
  "bindings": [],
  "hooks": {
    "enabled": false
  },
  "nodeHost": {
    "browserProxy": {
      "enabled": false
    }
  },
  "talk": {
    "interruptOnSpeech": false
  },
  "audio": {
    "transcription": {
      "command": ["whisper", "--model", "base"]
    }
  },
  "logging": {
    "level": "info",
    "consoleLevel": "info",
    "consoleStyle": "compact",
    "redactSensitive": "tools"
  },
  "update": {
    "channel": "stable",
    "checkOnStart": true
  },
  "diagnostics": {
    "enabled": true
  },
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "${AUTH_TOKEN}"
    }
  }
}
EOF
    
    # 创建鉴权文件（所有 provider 共用同一个 API Key）
    cat > ~/.openclaw/agents/main/agent/auth-profiles.json << EOF
{
  "version": 1,
  "profiles": {
    "api-proxy-gpt:default": {
      "type": "api_key",
      "provider": "api-proxy-gpt",
      "key": "${API_KEY}"
    },
    "api-proxy-claude:default": {
      "type": "api_key",
      "provider": "api-proxy-claude",
      "key": "${API_KEY}"
    },
    "api-proxy-deepseek:default": {
      "type": "api_key",
      "provider": "api-proxy-deepseek",
      "key": "${API_KEY}"
    },
    "api-proxy-google:default": {
      "type": "api_key",
      "provider": "api-proxy-google",
      "key": "${API_KEY}"
    },
    "api-proxy-glm:default": {
      "type": "api_key",
      "provider": "api-proxy-glm",
      "key": "${API_KEY}"
    },
    "api-proxy-minimax:default": {
      "type": "api_key",
      "provider": "api-proxy-minimax",
      "key": "${API_KEY}"
    },
    "api-proxy-qwen:default": {
      "type": "api_key",
      "provider": "api-proxy-qwen",
      "key": "${API_KEY}"
    },
    "api-proxy-xai:default": {
      "type": "api_key",
      "provider": "api-proxy-xai",
      "key": "${API_KEY}"
    }
  },
  "lastGood": {
    "api-proxy-gpt": "api-proxy-gpt:default",
    "api-proxy-claude": "api-proxy-claude:default",
    "api-proxy-deepseek": "api-proxy-deepseek:default",
    "api-proxy-google": "api-proxy-google:default",
    "api-proxy-glm": "api-proxy-glm:default",
    "api-proxy-minimax": "api-proxy-minimax:default",
    "api-proxy-qwen": "api-proxy-qwen:default",
    "api-proxy-xai": "api-proxy-xai:default"
  }
}
EOF
    
    # 创建工作空间配置
    cat > ~/.openclaw/workspace/AGENTS.md << 'AGENTS'
# AI 助手增强配置

你是一个超级 AI 助手，具备以下能力：

## 核心能力
1. **多模型协作**: 可以根据任务选择最合适的模型
2. **工具调用**: 熟练使用 GitHub、浏览器、视频处理等工具
3. **代码执行**: 可以运行 Python、Node.js、Bash 脚本
4. **网络搜索**: 通过浏览器获取实时信息
5. **文件处理**: 读写文件、处理图片视频

## 工作原则
- 主动思考，提供最优解决方案
- 使用工具前先解释原因
- 遇到问题时尝试多种方法
- 结果要准确、完整、易懂

## 特殊技能
- GitHub 操作：查看 issue、PR、代码
- 视频处理：提取关键帧、转换格式
- 数据分析：处理 CSV、JSON、统计分析
- 网页抓取：获取网页内容、提取数据
AGENTS

    cat > ~/.openclaw/workspace/TOOLS.md << 'TOOLS'
# 可用工具列表

## 开发工具
- `gh`: GitHub CLI（查看 issue、PR、仓库）
- `git`: 版本控制
- `node`: Node.js 运行时
- `python3`: Python 解释器

## 数据处理
- `jq`: JSON 处理
- `pandas`: 数据分析（Python）
- `numpy`: 数值计算（Python）

## 媒体工具
- `ffmpeg`: 视频处理
- `whisper`: 语音转文字
- `yt-dlp`: 下载视频
- `imagemagick`: 图片处理

## 系统工具
- `curl/wget`: 网络请求
- `rg`: 快速搜索（ripgrep）
- `fd`: 快速查找文件
- `bat`: 高亮显示文件内容

## 浏览器
- Chromium: 自动化浏览、截图、抓取
TOOLS
    
    # 设置权限
    chmod 700 ~/.openclaw
    chmod 600 ~/.openclaw/openclaw.json
    chmod 600 ~/.openclaw/agents/main/agent/auth-profiles.json
    
    log_success "配置文件创建完成（15个模型 + 完整工具集）"
}

# 安装系统依赖
install_dependencies() {
    log_info "安装系统依赖（完整工具集）..."
    
    apt-get update -qq
    
    # 安装 Chromium（浏览器控制）
    log_info "安装 Chromium 浏览器..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y chromium-browser chromium-chromedriver
    
    # 安装开发工具
    log_info "安装开发工具..."
    apt-get install -y git curl wget jq
    
    # 安装 GitHub CLI
    log_info "安装 GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    apt-get update -qq
    apt-get install -y gh
    
    # 安装媒体工具
    log_info "安装媒体处理工具..."
    apt-get install -y ffmpeg imagemagick graphicsmagick
    
    # 安装系统工具
    log_info "安装系统工具..."
    apt-get install -y ripgrep fd-find bat htop tree
    
    # 安装 Python 和 AI 工具
    log_info "安装 Python AI 工具..."
    apt-get install -y python3 python3-pip
    pip3 install -q openai-whisper yt-dlp pandas numpy requests beautifulsoup4
    
    log_success "系统依赖安装完成（20+ 工具）"
}

# 配置 Systemd 服务
setup_systemd() {
    log_info "配置 Systemd 服务..."
    
    mkdir -p ~/.config/systemd/user
    
    cat > ~/.config/systemd/user/openclaw-gateway.service << EOF
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/openclaw gateway --port 18789
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF
    
    # 启用 lingering（允许用户服务在登出后继续运行）
    loginctl enable-linger $USER
    
    # 重载 systemd
    systemctl --user daemon-reload
    
    # 启用并启动服务
    systemctl --user enable openclaw-gateway
    systemctl --user start openclaw-gateway
    
    log_success "Systemd 服务配置完成"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."
    
    sleep 5
    
    # 检查服务状态
    if systemctl --user is-active --quiet openclaw-gateway; then
        log_success "OpenClaw 服务运行正常"
    else
        log_error "OpenClaw 服务未运行"
        systemctl --user status openclaw-gateway
        exit 1
    fi
    
    # 检查端口
    if ss -tlnp | grep -q 18789; then
        log_success "Gateway 端口监听正常"
    else
        log_warning "Gateway 端口未监听，请检查日志"
    fi
    
    # 运行 doctor
    log_info "运行健康检查..."
    openclaw doctor || true
}

# 显示完成信息
show_completion() {
    echo
    echo "========================================="
    log_success "OpenClaw 超级 AI 助手安装完成！"
    echo "========================================="
    echo
    echo "📋 配置信息："
    echo "  - Gateway 端口: 18789"
    echo "  - Telegram Bot: 已配置"
    echo "  - API 服务商: $API_PROVIDER"
    echo "  - 模型数量: 15 个顶流模型"
    echo "  - 工具数量: 20+ 专业工具"
    echo
    echo "🤖 可用模型："
    echo "  - GPT-5.2 / GPT-5.2 Codex"
    echo "  - Claude Opus 4.5 (Thinking) / Claude Sonnet 4.5 (Thinking)"
    echo "  - DeepSeek V3.2 / DeepSeek V3.2 Thinking"
    echo "  - Gemini 3 Pro / Gemini 3 Pro Image"
    echo "  - GLM-4.7 / GLM-4.7 Thinking"
    echo "  - MiniMax M2.1"
    echo "  - Qwen3 Max"
    echo "  - Grok 4.1"
    echo
    echo "🛠️ 已安装工具："
    echo "  - AI/ML: Whisper, yt-dlp, Pandas, NumPy"
    echo "  - 开发: GitHub CLI, Git, Node.js, Python3"
    echo "  - 媒体: FFmpeg, ImageMagick, GraphicsMagick"
    echo "  - 系统: jq, ripgrep, fd, bat, htop"
    echo "  - 浏览器: Chromium (自动化)"
    echo
    echo "🚀 快速开始："
    echo "  1. 在 Telegram 中搜索你的 Bot"
    echo "  2. 发送任意消息开始对话"
    echo "  3. 发送 /model 查看并切换模型"
    echo
    echo "💡 试试这些："
    echo "  - '帮我查看 GitHub 上的热门项目'"
    echo "  - '下载这个视频并提取关键帧'"
    echo "  - '把这段音频转成文字'"
    echo "  - '今天天气怎么样'"
    echo "  - '用 Python 计算斐波那契数列'"
    echo
    echo "🔧 常用命令："
    echo "  - 查看服务状态: systemctl --user status openclaw-gateway"
    echo "  - 查看日志: journalctl --user -u openclaw-gateway -f"
    echo "  - 重启服务: systemctl --user restart openclaw-gateway"
    echo "  - 健康检查: openclaw doctor"
    echo "  - 查看技能: openclaw skills list"
    echo
    echo "📚 文档："
    echo "  - 官方文档: https://docs.openclaw.ai"
    echo "  - GitHub: https://github.com/openclaw/openclaw"
    echo
    echo "👨‍💻 关注我们："
    echo "  - 微信公众号搜索：AI安全工坊"
    echo "  - X (Twitter): https://x.com/JackW_AGI"
    echo "  - GitHub: https://github.com/taielab/openclaw-autopilot"
    echo
    echo "========================================="
}

# 主函数
main() {
    echo
    echo "========================================="
    echo "  OpenClaw AI 助手一键安装脚本 v1.6.0"
    echo "========================================="
    echo
    
    parse_args "$@"
    
    check_root
    check_system
    check_timezone
    check_firewall
    collect_config
    
    # 更新模式跳过配置
    if [ "$UPDATE_MODE" = true ]; then
        log_info "更新模式：仅升级 OpenClaw"
        install_nodejs
        install_openclaw
        systemctl --user restart openclaw-gateway 2>/dev/null || true
        log_success "更新完成！"
        openclaw --version
        exit 0
    fi
    
    echo
    log_info "开始安装..."
    echo
    
    install_nodejs
    install_openclaw
    install_dependencies
    configure_openclaw
    setup_systemd
    verify_installation
    
    show_completion
}

# 运行主函数
main "$@"
