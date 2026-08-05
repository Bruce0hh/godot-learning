# Godot 环境变量与快捷命令
#
# 用法（在仓库根目录）：
#   . .\scripts\godot-env.ps1     <- 注意开头那个点和空格，这叫 dot-source，
#                                    作用是把下面的变量/函数导入当前 shell
#   Edit-Game                     <- 打开编辑器
#   Run-Game                      <- 直接运行游戏
#   Import-Game                   <- 无界面重新导入资源（CI / 排查导入错误用）
#
# 故意不改系统 PATH：避免污染全局环境，换机器只要改这一行。

$GodotDir     = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe"
$Godot        = "$GodotDir\Godot_v4.7.1-stable_win64.exe"          # 常规版：不弹黑窗
$GodotConsole = "$GodotDir\Godot_v4.7.1-stable_win64_console.exe"  # 控制台版：stdout 能被 PowerShell 捕获

# 当前正在学习的项目。以后开第二个项目时改这里。
$ProjectPath = Join-Path (Split-Path $PSScriptRoot -Parent) "projects\01-platformer"

function Edit-Game   { & $Godot -e --path $ProjectPath }
function Run-Game    { & $Godot --path $ProjectPath }
function Import-Game { & $GodotConsole --headless --path $ProjectPath --import }
function Godot-Version { & $GodotConsole --version }

Write-Host "Godot 环境已载入" -ForegroundColor Green
Write-Host "  引擎: $Godot"
Write-Host "  项目: $ProjectPath"
Write-Host "  命令: Edit-Game / Run-Game / Import-Game / Godot-Version"
