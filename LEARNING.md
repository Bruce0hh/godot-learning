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

## ✅ 阶段 1 — 换素材 + 角色动画

**状态：已完成**（分支 `stage-1-animation`）

踩过的三个坑，值得记住：
1. **`$X` 按「名字」找节点，不是按「类型」** —— 把 `Sprite2D` 改类型成
   `AnimatedSprite2D` 后节点仍叫 `Sprite`，`$AnimatedSprite2D` 就找不到，
   返回 null，下一行调 `.play()` 直接炸。给 `@onready` 变量加类型标注
   （`: AnimatedSprite2D`）能让编辑器帮你查属性名。
2. **动画选择要和物理计算分开** —— 把 `play()` 散落在各个 if 里会互相覆盖，
   谁最后执行谁生效。正确做法是物理算完后，用一条 if/elif/else
   优先级链统一决定播哪个。
3. **`is_on_floor()` 返回上一次 `move_and_slide()` 的结果** —— 所以选动画的
   代码必须放在 `move_and_slide()` 之后，否则动画慢半拍。

遗留待改 → **已在「补丁 — 关卡边界 + 动画判据」中修复**：`run` 的判断曾用
`direction`（有没有按键）而不是 `velocity.x`（实际有没有动），顶着墙会「原地蹬腿」。

**学到：** `AnimatedSprite2D`、`SpriteFrames`（Speed FPS / 每帧 Duration / Loop）、
素材尺寸与 `scale` 的关系、渲染与物理是两套独立的东西（贴图 24px 而碰撞盒 32px
会让角色悬空）、动画状态机的分层。

---

## ✅ 阶段 2 — 用 TileMapLayer 画第一关

**状态：已完成**（分支 `stage-2-tilemap`）

成果：174 格瓦片，关卡 864×360（1.35 屏宽），6 条平台 + 一条通底地面，
临时的 `Ground` / `PlatformA` / `PlatformB` 已删除。
TileSet 存成独立资源 `assets/platformer.tres`。

踩过的四个坑：

1. **纹理参数不在 TileSet 上，在「图集源（AtlasSource）」上** —— TileSet 内部还有一层：
   ```
   TileSet（资源）
    └─ Source 0 : TileSetAtlasSource
        ├─ Texture             = tilemap.png
        ├─ Texture Region Size = (18,18)   ← 「从图片上裁多大一块」
        └─ Separation          = (1,1)
   ```
   TileSet 自己的 `tile_size` 是「地图网格一格多大」，两个都是 18 但**是两回事**。
   检视面板里永远看不到纹理参数，得先在**底部 TileSet 面板**建出源来。

2. **两个底部面板别搞混** —— 选中 TileSet **资源** → `TileSet` 面板（定义有哪些瓦片）；
   选中 `TileMapLayer` **节点** → `TileMap` 面板（把瓦片画进场景）。画不了东西通常是待错面板了。

3. **格子坐标可以是负数，Godot 不拦你** —— 第一次画时有 6 格画在了 `cy=-1`
   （世界 y = -18~0），全在视口外，白画。编辑器视口比游戏视口大，**红色横线才是 y=0**。

4. **`+` 按钮走文件对话框，路径不全会报「所选纹理无效」** —— 直接把 png
   从文件系统**拖进图块源列表**更稳。真遇到了就「项目 → 重新加载当前项目」。

**关键理解：** TileSet 是 Resource（数据定义 / 调色板，可被多个 Layer 复用），
TileMapLayer 是 Node（实例，存「坐标 → 图块 ID」的稀疏映射表）。
和阶段 1 的 `SpriteFrames`(Resource) vs `AnimatedSprite2D`(Node) 是同一个模式。
`tile_map_data` 序列化后是 `2 字节头 + 每格 12 字节`。

**关卡设计用得上的数字**（都由阶段 1 的物理参数推出来）：
- 一屏 = 640÷18 = **35.5 格**
- 角色高 24px = 1.33 格 → 通道至少 **2 格高**
- 跳跃高度 85px = 4.7 格 → 台阶最高 **4 格**；本关最紧的一跳抬升 72px，余量 13px

遗留待改 → **已在「补丁 — 关卡边界 + 动画判据」中修复**：`run` 的判断曾用
`direction` 而不是 `velocity.x`（本阶段没撞上是因为关卡里没有竖直墙面）。

**下阶段预告：** `Background` 只有 640×360，但关卡宽 864px —— 加相机后右边会露空白。

---

## ✅ 阶段 3 — 相机跟随

**状态：已完成**（分支 `stage-3-camera`）

成果：`player.tscn` 加了 `Camera2D` 子节点，关卡横向滚动、纵向锁死，
`Background` 调整为与相机视野完全重合的 `0,0 ~ 1008,360`。

**关键理解：相机不是"摄影机"，是一个坐标变换。**
Godot 拿 `Camera2D` 的变换求逆，当作**画布变换**作用在整个场景上 ——
相机右移 100px 等价于把世界左推 100px。这直接解释了阶段 4 的坑：
**HUD 必须放 `CanvasLayer`**，因为它是唯一不吃画布变换的节点。

**为什么当 Player 的子节点：** 节点树本来就有坐标继承，
相机位置自动等于玩家位置，跟随功能零代码。

> 阶段 1 的伏笔在这里兑现：如果当初转身是用 `Player.scale.x = -1` 实现的，
> 相机会跟着被镜像，每次转身画面都跳。用 `AnimatedSprite2D.flip_h`
> 只翻贴图、不动父节点变换 —— "物理归物理、动画归动画"第二次救场。

**两种"不要立刻跟上"，别搞混：**

| | Position Smoothing | Drag Margin |
|---|---|---|
| 行为 | 相机始终朝目标移动，但有缓动延迟 | 屏幕中央有死区矩形，角色在里面动相机不动 |
| 解决 | 移动生硬、镜头一顿一顿 | **跳跃时镜头上下抖** |
| 类比 | 低通滤波 | 死区 / 阈值 |

平台跳跃经典配方是「水平 Smoothing + 垂直 Drag」。本关垂直零自由度，
所以只用了 Smoothing（`speed = 8.0`；默认 5，2.0 会明显拖在角色后面）。

**Limit 限制的是「视口边缘」，不是相机中心** —— 直接填关卡的世界坐标边界，
不用自己减半屏宽。本关：

```
limit_left = 0     limit_top    = 0
limit_right= 1008  limit_bottom = 360     limit_smoothed = true

→ 相机中心可动范围 X: [320, 688]（368px 自由度）
                    Y: [180, 180]（零自由度 → 自动只横向滚）
```

**不需要写任何"锁定 Y 轴"的代码**，上下边界差正好等于视口高度就锁住了。
`Limit Smoothed` 配合 Position Smoothing 一起开，否则到边界会轻微抽搐。

**背景要和相机视野完全重合**：`0,0 ~ 1008,360`，一像素不多（浪费）不少（露边）。

**遗留的设计债：** `Limit` 是**关卡**的属性，却写死在 `player.tscn` 里 ——
阶段 6 做第二关时必然出问题。
正解：`TileMapLayer.get_used_rect()` 返回实际画了瓦片的格子范围，
× 18 就能自动算出 Limit，关卡画多大边界自动跟到多大。阶段 6 补上。

**学到：** `Camera2D`、画布变换（逆变换）、坐标继承、
Position Smoothing vs Drag Margin、Limit 语义、`limit_smoothed`

---

## ✅ 补丁 — 关卡边界 + 动画判据

**状态：已完成**（分支 `fix-level-boundaries`，在阶段 3 与 4 之间）

发现的真 bug：地面只铺在 `cx 0..55`，走出去下面是虚空，角色无限下落，
而相机被 `limit_left = 0` 钉住，你连他掉哪去了都看不见。

**两种边界哲学，别混：**

| | 墙（Wall） | 死亡区（Death Zone） |
|---|---|---|
| 行为 | 撞住，走不出去 | 掉出去 → 死亡 → 重开 |
| 用在哪 | **关卡左右边缘** | **关卡下方**（失足掉落） |
| 玩家感受 | "这里是世界的尽头" | "我失误了，重来" |
| 做的阶段 | 本补丁 | 阶段 5 |

**做法：把墙画在关卡范围之外**（`cx = -1` 和 `cx = 56`，即 `x = -18~0`
和 `1008~1026`）。相机边界是 `0 ~ 1008`，所以这两列**永远不出现在画面里** ——
既有实心边界，又不吃掉任何可见空间，等于用瓦片做了隐形墙。
墙高 `cy -1..17`，而角色在地面上最高只能跳到 `y = 221`，翻不过去。

**"暴露的表面要碰撞，埋起来的不要"** —— 墙最底下两格 `cy=18,19`
在地面表层之下，仍用无碰撞的填充块。规则不是"填充块永远没碰撞"，
而是看它**是不是暴露的表面**：这次给 `0:6`/`0:7` 补了碰撞，正因为它们要当墙。

**动画判据：意图 vs 结果**（收掉阶段 1 就欠着的遗留项）

```gdscript
if direction != 0.0:
    animated_sprite_2d.flip_h = direction < 0.0    # 意图：我面朝哪
...
elif abs(velocity.x) > 5.0:                        # 结果：我真的动了吗
    animated_sprite_2d.play("run")
```

`direction` 是 `Input.get_axis()` —— **「你按了什么」**；顶着墙时意图有、结果没有，
于是原地蹬腿。而 `move_and_slide()` 会按碰撞法线消掉撞进墙里的速度分量，
所以**调用之后**的 `velocity.x` 才是真实位移：

```
velocity.x = -200      （意图）
move_and_slide()       → 撞墙，法线分量被消掉 → velocity.x = 0
abs(0) > 5.0 → false   → idle ✅
```

**同一个函数里两个判断用不同数据源，因为它们问的是不同的问题。**
这是阶段 1「朝向是正交维度，要移出 if/elif 链」的延续。

阈值 `5.0` 不能省：松开按键后 `move_toward` 让 `velocity.x` 缓慢趋近 0，
用 `!= 0.0` 判断会让角色拖着 run 动画滑行。减速率 `200×10÷60 ≈ 33 px/帧`，
6 帧减到 0，阈值在最后一帧触发，看不出延迟。

**坑：** 手点出来的碰撞多边形绕序可能和「重置为默认图块形状」生成的相反。
`ConvexPolygonShape2D` 两种绕序都接受，但要用**调试 → 可见碰撞形状**实际确认，
静态看 `.tres` 是看不出来的。

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
