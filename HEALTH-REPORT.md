# Git 环境健康报告

**复检时间**：2026-10-03 22:22
**结论**：全部核心功能正常 ✅

## 一、Git 本体

| 项目 | 值 | 状态 |
|---|---|---|
| 版本 | `git version 2.56.0.windows.1` | ✅ |
| 位置 | `%LOCALAPPDATA%\Programs\MinGit` | ✅ |
| 体积 | 91.3 MB | — |
| PATH（用户变量） | 已包含 `…\MinGit\cmd` | ✅ |

## 二、身份与配置

| 配置项 | 值 |
|---|---|
| `user.name` | `NullVei115` |
| `user.email` | `2701212941@qq.com` |
| `core.sshCommand` | `C:/WINDOWS/System32/OpenSSH/ssh.exe` |
| `credential.helper` | `wincred` |
| `ssl.backend` | `schannel` |

## 三、SSH 通道实测

| 别名 | 实际地址 | 结果 |
|---|---|---|
| `github.com`（默认） | `ssh.github.com:443` | ✅ `Hi NullVei115!` |
| `github.com-22`（备用） | `github.com:22` | ❌ `Connection refused`（22 端口被阻断） |

> 结论：**必须走 443 通道**，默认配置已经是 443，无需干预。
> 注意 Windows OpenSSH 9.5p2 不会在多级 `Host` 之间自动回退，所以不能用"22 优先 + 自动切换"的写法。

## 四、git 实际操作

| 操作 | 结果 |
|---|---|
| `git fetch origin` | ✅ exit=0 |
| `git push` | ✅ exit=0（Everything up-to-date） |
| `git ls-remote origin` | ✅ 返回 `2160768…` |

## 五、仓库完整性

```
local  main = 2160768cbf628861416d707914b4e90f95d36dfd
remote main = 2160768cbf628861416d707914b4e90f95d36dfd    ← 一致
工作区干净：是
```

## 六、hosts 状态（已变化，需知悉）

复检发现：**Steamcommunity_302（Steam 社区加速工具）于 22:05:57 启动，22:07:48 重写了 hosts**，把之前对 GitHub 域名的解封全部覆盖回 `127.0.0.1`。

逐行比对确认，变化仅 5 行、无任何可疑域名新增：

```
[新增] # S302 BEGIN 4d37eb35a815bbf733279cf98dcc26e4
[新增] 127.0.0.1 api.steampowered.com #S302
[新增] # S302 END 4d37eb35a815bbf733279cf98dcc26e4
[删除] # S302 BEGIN befbd953c830139b7e2664d8f27976ef
[删除] # S302 END befbd953c830139b7e2664d8f27976ef
```

因该工具的整个托管区块会被整体重写，**区块内的手工修改无法持久**。

## ⚠️ 七、安全提示：HTTPS 流量正被本地解密

本机 `127.0.0.1:443` 由 `steamcommunity_302.cli.exe`（PID 6756）监听，它给 `github.com` 出示的是**自己签发的证书**：

```
Subject : (空)
Issuer  : CN=Steamcommunity302 - ECC Intermediate
```

而其根证书 `CN=Steamcommunity302 - 2026 ECC Root`（有效至 2036-08-11）已被安装进：

- `Cert:\CurrentUser\Root`
- `Cert:\LocalMachine\Root`

**这意味着该工具能够解密并查看/改写所有走 HTTPS 的 GitHub 流量**（包括 token、代码内容），而系统与浏览器不会给出任何警告。

### 影响范围

| 协议 | 是否受影响 | 说明 |
|---|---|---|
| **SSH**（本仓库使用） | ❌ 不受影响 | SSH 使用独立密钥交换，不依赖系统证书库 |
| HTTPS | ⚠️ 受中间人解密 | 建议避免用 HTTPS 传输敏感内容 |

### 建议

1. **本仓库继续用 SSH**（已配置好），敏感操作不受影响
2. 若要用 HTTPS 推代码，**先退出 Steamcommunity_302**，或在其设置中关闭对 GitHub 的代理
3. 若不希望该 CA 长期驻留，可在"受信任的根证书颁发机构"中删除 `Steamcommunity302 - 2026 ECC Root`（**注意：删除后该工具自身的加速功能会失效**）

---

*本报告由 DSH 自动生成，数据来自 2026-10-03 22:22 的实测。*
