# 玩家角色控制脚本
#
# extends CharacterBody2D —— 这个脚本挂在 CharacterBody2D 节点上。
# CharacterBody2D 是 Godot 给「玩家/敌人这类需要精确手感的角色」准备的物理体：
# 它不受引擎物理模拟推动，完全由你的代码决定怎么动 —— 这正是平台跳跃要的。
extends CharacterBody2D


# @export 让变量出现在编辑器右侧的「检视面板（Inspector）」里，
# 可以不改代码、边跑边调数值。调手感的时候这比改代码快 10 倍。
@export var speed: float = 200.0          # 水平移动速度（像素/秒）
@export var jump_velocity: float = -350.0 # 起跳初速度（负数 = 向上，Godot 2D 里 Y 轴朝下）

# 重力从项目设置里读，而不是硬编码一个数字。
# 好处：以后在「项目设置 → Physics → 2D → Default Gravity」改一次，
# 所有角色、敌人、掉落物统一生效。
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


# _physics_process 是「物理帧」回调，默认每秒固定 60 次。
# 所有涉及移动和碰撞的代码都要写在这里，不要写在 _process 里 ——
# _process 的调用频率跟显示器刷新率走，会导致高刷屏上手感不一致。
# delta = 距离上一物理帧过去了多少秒。
func _physics_process(delta: float) -> void:
	# ① 施加重力：只要人不在地面上，垂直速度就持续向下累加
	if not is_on_floor():
		velocity.y += gravity * delta

	# ② 跳跃：按下 jump 键 且 脚踩在地上
	# is_action_just_pressed = 只在「按下的那一帧」为 true（按住不会连跳）
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# ③ 水平移动
	# get_axis 把两个动作合成一个 -1.0 ~ 1.0 的值：
	# 只按左 = -1，只按右 = +1，都不按或同时按 = 0
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = direction * speed
		# 让贴图跟着朝向翻转（$Sprite 是 get_node("Sprite") 的简写）
		$Sprite.flip_h = direction < 0.0
	else:
		# move_toward(当前值, 目标值, 每帧最大变化量)
		# 用它做减速，松开按键后角色会滑一小段再停，比直接归零手感好
		velocity.x = move_toward(velocity.x, 0.0, speed * 10.0 * delta)

	# ④ 真正执行移动 + 碰撞处理。
	# 它会读取上面设好的 velocity，帮你处理撞墙、沿斜坡滑动、
	# 并更新 is_on_floor() / is_on_wall() 的状态。
	# ⚠️ 必须放在最后调用。
	move_and_slide()
