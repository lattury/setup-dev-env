---
name: setup_dev_env
description: |
  一键部署 Windows 开发环境：自动检测并安装 Node.js、Git（含离线安装包）和 CodeBuddy Code CLI，安装完成后自动启动登录配置。
  - MANDATORY TRIGGERS: 开发环境配置, 安装Git, 安装Node.js, 安装CodeBuddy, setup dev env, 环境部署
  - Use when: 用户需要在新电脑上配置开发环境、安装 Node.js / Git / CodeBuddy Code CLI
metadata:
  openclaw:
    os:
      - win32
---

# 开发环境一键部署

在新 Windows 机器上一键配置开发环境，按顺序完成以下步骤。

## 第一步：检查并安装 Node.js

1. 运行 `where node` 检查 Node.js 是否已安装
2. 如果已安装，输出 `node -v`，跳过安装
3. 如果未安装，静默安装本 skill 目录下的 `node-v24.14.0-x64.msi`（msiexec /qn 静默模式）
4. 安装完成后验证 `node -v` 和 `npm -v`

## 第二步：检查并安装 Git

1. 运行 `where git` 检查 Git 是否已安装
2. 如果 Git 已安装，输出 `git --version`，跳过安装
3. 如果 Git 未安装，静默安装本 skill 目录下的 `Git-2.53.0.2-64-bit.exe`（/VERYSILENT 模式）
4. 安装完成后验证 `git --version`

## 第三步：安装 CodeBuddy Code CLI

1. 确认 Node.js 可用（第一步可能刚安装）
2. 运行 `npm install -g @tencent-ai/codebuddy-code`
3. 安装完成后运行 `codebuddy --version` 验证

## 第四步：启动 CodeBuddy 登录配置

1. 安装完成后自动执行 `codebuddy --serve --open`
2. 这会启动 CodeBuddy 服务并自动在浏览器中打开 Web UI 登录页面
3. 用户在浏览器中选择登录方式（微信/Google/GitHub）完成认证
4. 登录成功后即可开始使用 CodeBuddy

## 完整一键部署

直接运行 `install.ps1` 即可，脚本会自动以管理员身份运行（无需手动右键提权）：
```powershell
powershell -ExecutionPolicy Bypass -File "$HOME/.openclaw/workspace/skills/setup-dev-env/install.ps1"
```

脚本内置自动提权逻辑：检测到非管理员运行时，会自动弹出 UAC 提权窗口重新以管理员身份启动自身。

## 分发到其他电脑

将整个 `setup-dev-env` 文件夹复制到目标机器的 `~/.openclaw/workspace/skills/` 目录下即可。文件夹内包含：
- `SKILL.md` — 技能描述文件
- `install.ps1` — 一键部署脚本（内置自动提权）
- `node-v24.14.0-x64.msi` — Node.js 离线安装包
- `Git-2.53.0.2-64-bit.exe` — Git 离线安装包

## 注意事项

- 脚本自动以管理员身份运行，会弹出 UAC 提权确认窗口，点击"是"即可
- 安装完成后可能需要重启终端才能在 PATH 中生效
