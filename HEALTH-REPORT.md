# Git 环境健康报告

**最新复检**：2026-10-03 22:33（Steamcommunity_302 清理后）
**结论**：全部核心功能正常，且**已恢复 GitHub 直连** ✅

---

## 一、重大变更：已清理 Steamcommunity_302

### 变更原因

该工具（便携版 v15.0.7）在开机时自动运行，会：

1. **重写 hosts**，把 633 个域名指向 `127.0.0.1`（其中 41 条是 GitHub 域名）
2. 在 `127.0.0.1:443` 运行本地代理，并**对自己代理的域名做 HTTPS 中间人解密**

其根证书 `CN=Steamcommunity302 - 2026 ECC Root` 曾被装入 `CurrentUser\Root` 与 `LocalMachine\Root`，因此浏览器与命令行都不会告警。这意味着它能够读取和改写这些域名的 HTTPS 内容（包括 token、代码）。

### 已执行的清理

| 操作 | 结果 |
|---|---|
| 停止 S302 全部进程 | ✅ 0 个残留 |
| 禁用计划任务 `Steamcommunity302 V15` / `V15 UI` | ✅ 均已 Disabled |
| 移除 Steam 开机自启（HKCU Run） | ✅ 已移除 |
| 清理 hosts | ✅ 660 行 → **23 行**（仅剩 Windows 默认模板），0 条劫持 |
| 删除中间人根证书（LocalMachine\Root / CurrentUser\Root / CA） | ✅ 全部 0 残留 |
| 刷新 DNS | ✅ 已完成 |

> 所有变更前均已备份至 `s302-cleanup-backup\`：hosts 原文（24873 字节）、根证书 `.cer`、两个计划任务定义 XML、注册表 `HKCU-Run.reg`。

### 清理前后对比（实测数据）

| 检查项 | 清理前 | 清理后 |
|---|---|---|
| `github.com` 解析 | `127.0.0.1`（劫持） | `20.205.243.166`（真实） |
| `github.com` 证书签发者 | `Steamcommunity302 - ECC Intermediate` | `Sectigo Public Server Authentication CA DV E36` |
| 系统严格证书校验 | （被中间人） | ✅ 有效且被系统信任 |
| `raw.githubusercontent.com` | 间歇性 `000` | ✅ 稳定 `200` |
| SSH `github.com:22` | Connection refused | ✅ `Hi NullVei115!` |
| SSH `ssh.github.com:443` | ✅ | ✅ |

**重要修正**：此前判断的"GitHub 被网络封锁 / 部分 IP 不可用"是**误判**。实测证明那些失败全部由 Steamcommunity_302 的本地代理造成；`github.com`、`api.github.com`、`raw.githubusercontent.com`、`codeload.github.com`、`avatars.githubusercontent.com` 现已全部直连 `200`。

---

## 二、Git 本体

| 项目 | 值 | 状态 |
|---|---|---|
| 版本 | `git version 2.56.0.windows.1` | ✅ |
| 位置 | `%LOCALAPPDATA%\Programs\MinGit` | ✅ |
| 体积 | 91.3 MB | — |
| PATH（用户变量） | 已包含 `…\MinGit\cmd` | ✅ |

## 三、身份与配置

| 配置项 | 值 |
|---|---|
| `user.name` | `NullVei115` |
| `user.email` | `2701212941@qq.com` |
| `core.sshCommand` | `C:/WINDOWS/System32/OpenSSH/ssh.exe` |
| `credential.helper` | `wincred` |
| `ssl.backend` | `schannel` |

## 四、SSH 通道（清理后两条均可用）

| 别名 | 实际地址 | 结果 |
|---|---|---|
| `github.com`（默认） | `ssh.github.com:443` | ✅ `Hi NullVei115!` |
| `github.com-22`（备用） | `github.com:22` | ✅ `Hi NullVei115!` |

> 说明：Windows OpenSSH 9.5p2 **不会**在多级 `Host` 之间自动回退，因此默认通道直接指向 443。现在 22 端口也已恢复，如需切换：
> `git remote set-url origin git@github.com-22:NullVei115/dsh.git`（切 22）/ `git@github.com:NullVei115/dsh.git`（切回 443）

## 五、git 实际操作

| 操作 | 结果 |
|---|---|
| `git fetch origin` | ✅ exit=0 |
| `git push` | ✅ exit=0（`10cc540..733226f` push 成功） |
| `git ls-remote origin` | ✅ 返回最新 SHA |

## 六、已知的小问题

| 域名 | 状态 | 说明 |
|---|---|---|
| `gist.github.com` | ❌ 连接失败 | DNS 被污染至 `8.7.198.45`，用真实 GitHub IP 直连亦不通，属 SNI 级封锁。不影响日常开发（gist 为可选的代码片段服务） |
| 其余 GitHub 域名 | ✅ 全部正常 | — |

---

## 附：如果将来仍需要访问被封锁的域名

Steamcommunity_302 的做法是"劫持 + 本地中间人解密"，安全性差。更安全的替代方案：

- **代理类**：Clash / mihomo 等，采用 CONNECT 隧道转发，**不解密 TLS**，无需安装根证书
- **只加速特定域名**：切勿全局修改 hosts，优先使用代理软件的规则模式

无论使用哪种方案，**都应避免安装来源不明的根证书到系统信任库**。

---

*本报告由 DSH 生成，数据来自 2026-10-03 22:33 的实测。*
