# Godot 学习路线图 · 01-platformer

**玩法**：每个阶段开一个分支做，做完合回 `main`。这样 git 历史本身就是你的学习记录，
`git log` 一拉就知道自己走到哪、每一步学了什么。

```powershell
git checkout -b stage-1-animation    # 开始
# ... 写代码 ...
git commit -am "stage 1: 角色动画"
git checkout main; git merge stage-1-animation   # 完成
```

**每阶段的规矩**：先自己写，卡住超过 30 分钟再查文档或问 AI，
问「为什么」不问「给我代码」（理由见 [README](README.md#怎么用-ai-辅助学习重要)）。

---

## ✅ 阶段 0 — 环境 + 仓库 + 可跑骨架

**状态：已完成**（这就是当前仓库的内容）

学到的东西：
- **节点（Node）与场景（Scene）**：场景就是一棵节点树，可以被当成一个节点复用。
  `player.tscn` 被 `main.tscn` 实例化，就是这个机制。
- **`_physics_process(delta)`**：固定 60Hz 的物理帧回调，所有移动代码写这里。
- **`CharacterBody2D` + `move_and_slide()`**：手感由代码决定的角色物理体。
- **输入映射（Input Map）**：用自定义动作名而不是硬编码按键。

验收：`Run-Game` 后角色会掉到地面上，能左右走、能跳上两块平台。

---

## ☐ 阶段 1 — 换素材 + 角色动画

把方块换成真正的角色，加上待机 / 跑动 / 跳跃三套动画。

**要做的：**
1. 去 [Kenney - Pixel Platformer](https://kenney.nl/assets/pixel-platformer) 下载（CC0，可商用免署名），
   解压到 `projects/01-platformer/assets/sprites/`
2. 把 `player.tscn` 里的 `Sprite2D` 换成 **`AnimatedSprite2D`**
3. 在检视面板里新建 `SpriteFrames` 资源，建 `idle` / `run` / `jump` 三个动画
4. 在 `player.gd` 里根据 `velocity` 和 `is_on_floor()` 切换动画

**学到：** `AnimatedSprite2D`、`SpriteFrames`、纹理导入设置、动画状态切换逻辑

**验收：** 站着播 idle，跑动播 run，腾空播 jump，转身时贴图翻转

**坑：** 素材糊成一团 → 检查纹理的导入设置里 Filter 是否关掉（项目已全局设为 Nearest，
但单个纹理可以覆盖）

---

## ☐ 阶段 2 — 用 TileMapLayer 画第一关

删掉临时的 ColorRect 平台，用瓦片地图画一个真正的关卡。

**要做的：**
1. 加 `TileMapLayer` 节点（⚠️ Godot 4.3 起 `TileMap` 已废弃，用 `TileMapLayer`）
2. 用 Kenney 的地块图集建 `TileSet`
3. 给地块加**物理层（Physics Layer）**，否则角色会穿过去
4. 画一个有高低差、需要连续跳跃才能通过的关卡

**学到：** `TileMapLayer`、`TileSet`、图集切分、物理层、碰撞多边形

**验收：** 关卡比一屏宽，角色能跳上跳下，不会穿模

**坑：** 画好了但角色掉下去 → 99% 是忘了在 TileSet 里给地块画碰撞多边形

---

## ☐ 阶段 3 — 相机跟随

关卡比屏幕大了，需要相机跟着角色走。

**要做的：**
1. 在 `player.tscn` 里给 Player 加一个 `Camera2D` 子节点
2. 打开 **Position Smoothing**，调 speed 到手感舒服
3. 设 **Limit**（上下左右边界），别让相机拍到关卡外面的虚空

**学到：** `Camera2D`、平滑跟随、相机边界

**验收：** 走到关卡边缘时相机停住，不会露出黑边

---

## ☐ 阶段 4 — 金币收集 + HUD ⭐ 本阶段最重要

这是整条路线里概念密度最高的一关 —— **信号（Signal）** 是 Godot 的灵魂。

**要做的：**
1. 建 `coin.tscn`：`Area2D` + `Sprite` + `CollisionShape2D`
2. 连接 `body_entered` 信号，玩家碰到就 `queue_free()` 自己
3. 金币发出自定义信号 `signal collected`
4. 建 HUD：`CanvasLayer` + `Label` 显示数量（用 CanvasLayer 才不会跟着相机跑）
5. 用信号把「金币被吃」传给 HUD 更新数字

**学到：** `Area2D`、**自定义信号 `signal` / `emit()`**、`CanvasLayer`、`queue_free()`、
节点间通信的正确姿势

**关键理解：** 为什么用信号，不让金币直接 `get_parent().get_node("HUD").count += 1`？
—— 因为那样金币就**写死**依赖了场景结构，换个关卡就崩。
信号让「谁发生了什么」和「谁关心这件事」解耦。想清楚这一点，你就入门了。

**验收：** 走过金币会消失，右上角数字 +1

---

## ☐ 阶段 5 — 敌人 + 死亡重开

**要做的：**
1. 建 `enemy.tscn`：会左右巡逻的 `CharacterBody2D`（碰到墙就掉头）
2. 玩家从上方踩中 → 敌人死；从侧面碰到 → 玩家死
3. 玩家死亡 → 延迟一下 → `get_tree().reload_current_scene()`
4. 掉出关卡底部也算死（加个大 `Area2D` 当死亡区）

**学到：** **碰撞层 / 碰撞掩码（Layer / Mask）**、`get_slide_collision()`、
`Timer` 节点、场景重载

**关键理解：** 碰撞层和掩码是新手第二大坑。
「层」= 我是什么；「掩码」= 我能撞到什么。两者不对称，要分开想。

**验收：** 踩敌人能踩死，被撞会死并重开关卡

---

## ☐ 阶段 6 — 音效 + BGM + 多关卡

**要做的：**
1. `AudioStreamPlayer` 播 BGM（[Kenney 也有免费音效](https://kenney.nl/assets/category:Audio)）
2. 跳跃 / 吃金币 / 死亡各加音效
3. 建第二关，走到终点旗子切换场景
4. 建一个 **Autoload 单例** `GameState.gd` 存总分，跨场景不丢

**学到：** `AudioStreamPlayer` / `AudioStreamPlayer2D`、音频总线、
`get_tree().change_scene_to_file()`、**Autoload（自动加载单例）**

**坑：** 切场景后分数归零 → 说明数据存在场景节点里了，要放进 Autoload

---

## ☐ 阶段 7 — 导出，发给别人玩 🎉

**要做的：**
1. 编辑器 → 项目 → 导出，先装 **Export Templates**（第一次要下载 ~1GB）
2. 导出 Windows 版到 `builds/`（`.gitignore` 已经忽略这个目录了）
3. 导出 **Web 版**，传到 [itch.io](https://itch.io/) —— 项目已配 `gl_compatibility`
   渲染后端，就是为了这一步能成
4. 把链接发给朋友

**学到：** 导出模板、导出预设、Web 导出的限制

**验收：** 别人在浏览器里点开就能玩你的游戏。

> ⚠️ `export_presets.cfg` 被 `.gitignore` 忽略了（它可能存签名密码）。
> 这意味着导出配置不会进 git，换机器要重配一次 —— 这是安全性换来的代价，值得。

---

## 学完之后

7 个阶段跑完，你已经具备独立做小游戏的能力了。接下来的方向：

- **做 game jam**：[Ludum Dare](https://ldjam.com/)、[itch.io jams](https://itch.io/jams)，48 小时逼自己做完一个
- **开第二个项目**：`projects/02-xxx/`，换个题材（俯视角 RPG / 塔防 / Roguelite）
- **学 Shader**：Godot 的 `.gdshader`，做屏幕特效和水面波纹
- **读官方 demo 源码**：[godot-demo-projects](https://github.com/godotengine/godot-demo-projects)
