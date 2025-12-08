class_name VelocityBasedRotation
extends Node

@export var enabled: bool = true:
	set = _set_enabled
@export var target: Node2D
@export_range(0.25, 1.5) var lerp_seconds := 0.4 # 旋转到指定角度所需秒数
@export var rotation_multiplier := 120 # 旋转角度
@export var x_velocity_threshold := 3.0 # 发生旋转的x方向上速度阈值

var last_position: Vector2
var velocity: Vector2
var angle: float
var progress: float
var time_elapsed := 0.0


func _ready():
	pass


func _process(delta: float) -> void:
	if not enabled or not target:
		return

	velocity = target.global_position - last_position
	last_position = target.global_position
	progress = time_elapsed / lerp_seconds

	# 目标角度
	if abs(velocity.x) > x_velocity_threshold:
		angle = velocity.normalized().x * rotation_multiplier * delta
	else:
		angle = 0.0

	# 平滑旋转
	target.rotation = lerp_angle(target.rotation, angle, progress)
	time_elapsed += delta

	if progress >= 1.0:
		time_elapsed = 0.0


func _set_enabled(value: bool):
	enabled = value
	
	if target and not enabled:
		target.rotation = 0.0
