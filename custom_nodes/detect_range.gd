class_name DetectRange
extends Area2D

@export var col_shape: CollisionShape2D
@export var base_range_size: float
@export var stats: UnitStats:
	set(value):
		stats = value
		# 侦测范围图层为 player：4， enemy：8； mask为player：2， enemy：1
		collision_layer = 1 << (stats.team + 2)
		collision_mask = 2 >> stats.team

		var shape := CircleShape2D.new()
		shape.radius = base_range_size * stats.attack_range
		col_shape.shape = shape
