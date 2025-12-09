class_name VelocityBasedRotation
extends Node

@export var enabled: bool = true:
	set = _set_enabled
@export var target: Node2D
@export_range(0.25, 1.5) var lerp_seconds := 0.4 # 旋转到指定角度所需秒数
@export var rotation_multiplier := 120 # 最大旋转角度（角度制）
@export var x_velocity_threshold := 300.0 # 发生旋转的x方向上速度阈值 (像素/秒)

var last_position: Vector2
var velocity: Vector2


func _ready():
	if target:
		last_position = target.global_position


func _process(delta: float) -> void:
	if not enabled or not target:
		return

	var current_position = target.global_position
	
	# 1. 计算真实速度 (像素/秒)，使其与帧率无关
	if delta > 0:
		velocity = (current_position - last_position) / delta
	else:
		velocity = Vector2.ZERO
		
	last_position = current_position

	var target_angle := 0.0

	# 2. 计算目标角度
	# rotation_multiplier 视为角度（Degree）
	if abs(velocity.x) > x_velocity_threshold:
		target_angle = sign(velocity.x) * deg_to_rad(rotation_multiplier)
	
	# 3. 平滑旋转 (Time-independent smoothing)
	# 这里的系数 3.0 确保在 lerp_seconds 时间内完成约 95% 的旋转过渡
	# 使用 1 - exp(-decay * delta) 公式进行帧率无关的指数平滑
	var decay = 3.0 / lerp_seconds
	var weight = 1.0 - exp(-decay * delta)
	
	target.rotation = lerp_angle(target.rotation, target_angle, weight)


func _set_enabled(value: bool):
	enabled = value
	
	if target:
		if enabled:
			# 启用时重置上一帧位置，防止因位置突变产生错误的瞬间高速
			last_position = target.global_position
		else:
			target.rotation = 0.0
