<#
.SYNOPSIS
Oculink eGPU 热插拔管理脚本 (Windows 版)
#>

# 1. 自动请求管理员权限
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "正在请求管理员权限..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 2. 定义主菜单循环
do {
    Clear-Host
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "         Oculink eGPU 热插拔管理助手 (Windows)     " -ForegroundColor Cyan
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "  1. 扫描硬件改动 (插入 Oculink 并通电后执行)"
    Write-Host "  2. 启用 / 禁用 外接显卡 (准备拔出前必须禁用)"
    Write-Host "  3. 退出"
    Write-Host "=================================================" -ForegroundColor Cyan
    
    $Choice = Read-Host "请选择操作 [1-3]"

    switch ($Choice) {
        '1' {
            Write-Host "正在呼叫系统扫描即插即用硬件设备..." -ForegroundColor Yellow
            # 调用 Windows 自带的 PnP 工具扫描硬件
            pnputil /scan-devices
            Write-Host "扫描完成！如果您已连接并开启 eGPU，它应该已经上线。" -ForegroundColor Green
            Pause
        }
        '2' {
            Write-Host "当前系统中的显示适配器 (显卡) 如下：" -ForegroundColor Yellow
            Write-Host "-------------------------------------------------"
            
            # 获取所有显卡设备
            $GPUs = Get-PnpDevice -Class Display | Select-Object Status, FriendlyName, InstanceId
            
            for ($i = 0; $i -lt $GPUs.Count; $i++) {
                $StatusColor = if ($GPUs[$i].Status -eq "OK") { "Green" } elseif ($GPUs[$i].Status -eq "Error") { "Red" } else { "DarkGray" }
                Write-Host "  [$($i + 1)] $($GPUs[$i].FriendlyName) " -NoNewline
                Write-Host "(当前状态: $($GPUs[$i].Status))" -ForegroundColor $StatusColor
            }
            Write-Host "-------------------------------------------------"
            
            $GpuIndex = Read-Host "请输入要操作的显卡序号 (如输入 1, 或按 Enter 返回)"
            if ([string]::IsNullOrWhiteSpace($GpuIndex)) { continue }
            
            try {
                $SelectedGPU = $GPUs[[int]$GpuIndex - 1]
                if ($SelectedGPU.Status -eq "OK") {
                    Write-Host "警告: 禁用前请确保已关闭所有正在使用该显卡的程序（游戏、浏览器、渲染软件等）！" -ForegroundColor Red
                    $Confirm = Read-Host "确定要【禁用】 $($SelectedGPU.FriendlyName) 吗？(y/n)"
                    if ($Confirm -match "^[yY]$") {
                        Write-Host "正在禁用设备，屏幕可能会闪烁，请稍候..." -ForegroundColor Yellow
                        Disable-PnpDevice -InstanceId $SelectedGPU.InstanceId -Confirm:$false
                        Write-Host "禁用成功！现在您可以安全拔出 Oculink 线缆了。" -ForegroundColor Green
                    }
                } else {
                    $Confirm = Read-Host "确定要【启用】 $($SelectedGPU.FriendlyName) 吗？(y/n)"
                    if ($Confirm -match "^[yY]$") {
                        Write-Host "正在启用设备，屏幕可能会闪烁，请稍候..." -ForegroundColor Yellow
                        Enable-PnpDevice -InstanceId $SelectedGPU.InstanceId -Confirm:$false
                        Write-Host "启用成功！" -ForegroundColor Green
                    }
                }
            } catch {
                Write-Host "输入无效或操作失败。" -ForegroundColor Red
            }
            Pause
        }
        '3' {
            Write-Host "已退出。"
            Exit
        }
        default {
            Write-Host "选择无效，请重试。" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)