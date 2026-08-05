# Godot 学习仓库

用来系统学习 [Godot](https://godotengine.org/) 游戏引擎的个人仓库。
第一个项目是 **2D 平台跳跃**，学习路线见 [LEARNING.md](LEARNING.md)。

- 引擎版本：**Godot 4.7.1 stable**（标准版，非 Mono）
- 脚本语言：**GDScript**
- 平台：Windows

---

## 快速开始

```powershell
# 1. 载入环境（注意开头的「点 + 空格」，这叫 dot-source）
. .\scripts\godot-env.ps1

# 2. 直接跑游戏
Run-Game

# 3. 打开编辑器
Edit-Game
```

跑起来后：**A / ←** 左移，**D / →** 右移，**空格 / W / ↑** 跳跃。

> 引擎路径写在 `scripts/godot-env.ps1` 里，没有污染系统 PATH。
> 换机器或升级引擎，只需要改那个文件里的一行。

---

## 目录结构

```
.
├─ LEARNING.md              学习路线图（8 个阶段，带进度复选框）
├─ scripts/
│  └─ godot-env.ps1         引擎路径 + Run-Game / Edit-Game / Import-Game
├─ docs/notes/              每个阶段的踩坑笔记
└─ projects/
   └─ 01-platformer/        第一个项目
      ├─ project.godot      项目设置（含输入映射，有详细注释）
      ├─ scenes/
      │  ├─ main.tscn       主场景：地面 + 两块浮空平台 + 玩家
      │  └─ player.tscn     玩家场景：CharacterBody2D + Sprite + 碰撞体
      ├─ scripts/
      │  └─ player.gd       移动/跳跃逻辑（逐行注释）
      └─ assets/            素材（sprites / audio）
```

以后开第二个项目就加 `projects/02-xxx/`，不用重建仓库 ——
整条学习轨迹留在同一份 git 历史里。

---

## 当前骨架做了什么

一个**最小可玩**的平台跳跃：重力、左右移动、松键减速、地面判定、跳跃、
朝向翻转，以及一个能跳上去的关卡。约 25 行 GDScript，每行都有注释。

关卡、动画、敌人、收集品、UI、音效、导出 —— 这些是 LEARNING.md 里
阶段 1~7 的**练习内容**，故意没有实现。

---

## 怎么用 AI 辅助学习（重要）

这个仓库的目的是**让你学会 Godot**，不是让你拥有一个游戏。所以：

**✅ 该找 AI 做的：**
- 解释概念："信号（signal）到底解决了什么问题？为什么不直接调用父节点的方法？"
- Review 代码："我这样写敌人巡逻对吗？有什么 Godot 里更地道的写法？"
- 定位 bug："角色卡在墙上抖动，贴了报错和代码，帮我看哪错了"
- 查文档："4.7 里 TileMap 换成 TileMapLayer 了，迁移要注意什么？"

**❌ 不该找 AI 做的：**
- "帮我把阶段 4 实现了" —— 直接给完整实现，你就什么都没学到

**卡住的规矩**：先自己试 **30 分钟**。查[官方文档](https://docs.godotengine.org/zh-cn/4.x/)、
看报错、加 `print()` 打印变量。真的卡死了再问，而且要问「为什么」而不是「给我代码」。

---

## 常用参考

- [官方文档（中文）](https://docs.godotengine.org/zh-cn/4.x/)
- [官方入门教程 Dodge the Creeps](https://docs.godotengine.org/zh-cn/4.x/getting_started/first_2d_game/index.html)
- [Kenney 免费素材（CC0，可商用免署名）](https://kenney.nl/assets)
- [GDQuest 教程](https://www.gdquest.com/)
- [Godot 中文社区](https://godotengine.org.cn/)
