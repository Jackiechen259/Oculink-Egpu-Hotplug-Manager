# Oculink eGPU Hotplug Manager (Windows)

基于 PowerShell 的工具，帮助在 Windows 上以软件方式管理通过 Oculink 直连的外接显卡（eGPU），提供扫描、启用/禁用与安全拔出流程，旨在降低热插拔带来的系统风险。

主要功能

- 扫描并识别外接显卡
- 软件层启用 / 禁用设备（用于安全拔出）

要求

- Windows 10/11
- 以管理员身份运行 PowerShell
- 仓库内脚本：egpu.ps1

快速使用

1. 物理连接并给 eGPU 供电。
1. 以管理员身份运行：

```powershell
PowerShell -ExecutionPolicy Bypass -File .\egpu.ps1
```

1. 按提示选择：扫描（扫描硬件变更）或启用/禁用（用于安全拔出或恢复设备）。

注意事项

- 在禁用设备前请先关闭所有使用显卡的应用程序。
- 如果使用封装为 `.exe` 的版本，杀毒软件可能误报；首选运行 `.ps1` 脚本或手动信任程序。

许可证与免责声明

- 查看仓库中的 `LICENSE` 获取许可信息。
- 本工具封装系统 API，热插拔操作存在硬件风险。作者不对因此产生的任何损失负责。
