# git 环境自检脚本
# 逐项报告本机 Git 配置与 GitHub 连通性。

$ErrorActionPreference = 'Continue'
$ok = 0; $fail = 0

function Report($name, $good, $detail) {
    if ($good) { $script:ok++;  Write-Host "[ OK ]" -ForegroundColor Green -NoNewline }
    else       { $script:fail++; Write-Host "[FAIL]" -ForegroundColor Red   -NoNewline }
    Write-Host "  $name" -NoNewline
    if ($detail) { Write-Host "  -> $detail" -ForegroundColor DarkGray } else { Write-Host "" }
}

Write-Host "`n=== Git 环境自检 ===`n" -ForegroundColor Cyan

# 1. Git 是否可用
try {
    $version = (& git --version 2>&1) -join ''
    Report "Git 可执行" ($LASTEXITCODE -eq 0) $version
} catch {
    Report "Git 可执行" $false "未找到 git，请检查 PATH"
}

# 2. 提交身份
$name  = (& git config --global --get user.name  2>&1) -join ''
$email = (& git config --global --get user.email 2>&1) -join ''
Report "user.name 已配置"  ([bool]$name)  $name
Report "user.email 已配置" ([bool]$email) $email

# 3. 当前仓库
if (Test-Path .git) {
    $branch = (& git branch --show-current 2>&1) -join ''
    Report "位于 git 仓库内" $true "分支: $branch"
    $head = (& git log --oneline -1 2>&1) -join ''
    Report "存在提交记录" ($LASTEXITCODE -eq 0) $head
    $remote = (& git remote get-url origin 2>&1) -join ''
    Report "已配置 origin" ([bool]$remote) $remote
} else {
    Report "位于 git 仓库内" $false "当前目录不是仓库"
}

# 4. SSH 认证
Write-Host "`n--- GitHub SSH 认证 ---" -ForegroundColor Cyan
$sshOut = (& ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 -T git@github.com 2>&1) -join "`n"
if ($sshOut -match 'successfully authenticated') {
    $who = if ($sshOut -match 'Hi ([^!]+)!') { $Matches[1] } else { '?' }
    Report "SSH 认证" $true "已认证为 $who"
} else {
    Report "SSH 认证" $false "认证失败（公钥是否已加到 GitHub？）"
}

# 5. 远端可达
Write-Host "`n--- 远端连通性 ---" -ForegroundColor Cyan
if (Test-Path .git) {
    & git ls-remote --heads origin > $null 2>&1
    Report "origin 可达（读写权限已验证）" ($LASTEXITCODE -eq 0) "git ls-remote 退出码 $LASTEXITCODE"
}

# 汇总
Write-Host "`n=== 结果: $ok 项通过, $fail 项失败 ===`n" -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Yellow' })
exit $fail
