# git-first-push

这是 `NullVei115` 在这台 Windows 机器上完成的**第一次 GitHub 推送**，用于验证完整的 Git 工作流。

## 目的

在 **360 安全卫士会拦截静默安装**、**GitHub 官方下载域名被阻断**的环境下，验证以下链路全部可用：

| 环节 | 说明 |
|---|---|
| Git 本体 | MinGit 2.56.0，免安装部署到 `%LOCALAPPDATA%\Programs\MinGit` |
| 认证方式 | SSH（ed25519），走系统自带 OpenSSH |
| 提交署名 | `NullVei115 <2701212941@qq.com>` |

## 如何使用

在 PowerShell 里运行自检脚本：

```powershell
pwsh -File .\check-git-setup.ps1
```

它会逐项报告 Git 版本、提交身份、SSH 认证状态和远端连接情况。

## 环境说明

- **操作系统**：Windows
- **Git 版本**：2.56.0.windows.1
- **SSH 客户端**：`C:/WINDOWS/System32/OpenSSH/ssh.exe`
- **备用通道**：`ssh.github.com:443`（当 22 端口不可用时）

## 仓库信息

- **地址**：https://github.com/NullVei115/dsh
- **SSH 远端**：`git@github.com:NullVei115/dsh.git`
- **默认分支**：`main`

## 日常使用

```powershell
git add -A
git commit -m "说明这次改了什么"
git push
```

首次推送后 `origin/main` 已建立跟踪关系，之后直接 `git push` / `git pull` 即可，无需再带参数。

## 许可

MIT
