@tool
class_name Unit
extends Area2D

@export var stats: UnitStats:
	set = set_stats

@onready var skin: Sprite2D = $Skin
@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar


func set_stats(new_stats: UnitStats) -> void:
	stats = new_stats

	if new_stats == null:
		return

	if not is_node_ready():
		await ready

	# 设置皮肤贴图区域
	skin.region_rect.position = Vector2(stats.skin_coordinates) * Arena.CELL_SIZE
