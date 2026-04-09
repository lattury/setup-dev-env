---
name: setup_dev_env
description: |
  One-click Windows dev environment setup: auto-detect and install Node.js, Git (with offline installers from GitHub Releases) and CodeBuddy Code CLI, then auto-launch login.
  - MANDATORY TRIGGERS: dev environment setup, install Git, install Node.js, install CodeBuddy, setup dev env
  - Use when: user needs to set up a dev environment on a new Windows machine, install Node.js / Git / CodeBuddy Code CLI
metadata:
  openclaw:
    os:
      - win32
---

# Dev Environment One-Click Setup

Set up a complete Windows dev environment on a new machine in one click.

## Step 1: Check and install Node.js

1. Run `where node` to check if Node.js is installed
2. If installed, output `node -v` and skip
3. If not installed, look for `node-v24.14.0-x64.msi` in the skill directory; if missing, auto-download from GitHub Releases
4. Silent install via `msiexec /qn`, then verify with `node -v`

## Step 2: Check and install Git

1. Run `where git` to check if Git is installed
2. If installed, output `git --version` and skip
3. If not installed, look for `Git-2.53.0.2-64-bit.exe` in the skill directory; if missing, auto-download from GitHub Releases
4. Silent install via `/VERYSILENT`, then verify with `git --version`

## Step 3: Install CodeBuddy Code CLI

1. Confirm Node.js is available (may have just been installed)
2. Run `npm install -g @tencent-ai/codebuddy-code`
3. Verify with `codebuddy --version`

## Step 4: Launch CodeBuddy login

1. Auto-run `codebuddy --serve --open`
2. Browser opens the Web UI login page automatically
3. User selects login method (WeChat/Google/GitHub) to authenticate
4. Once logged in, CodeBuddy is ready to use

## One-click deployment

Just run `install.ps1` — it auto-elevates to Administrator (UAC prompt):
```powershell
powershell -ExecutionPolicy Bypass -File "$HOME/.openclaw/workspace/skills/setup-dev-env/install.ps1"
```

## Installing this skill on another machine

### Option A: From ClawHub (if published)
```bash
openclaw skills install setup-dev-env
```

### Option B: From GitHub
```bash
git clone https://github.com/lattury/setup-dev-env.git ~/.openclaw/workspace/skills/setup-dev-env
```

In both cases, the install script will auto-download the offline installers (Node.js, Git) from GitHub Releases if they are not present locally.

## Notes

- The script auto-elevates to Administrator — just click "Yes" on the UAC prompt
- Offline installers are downloaded from GitHub Releases on first run if not included locally
- After installation, you may need to restart the terminal for PATH changes to take effect
