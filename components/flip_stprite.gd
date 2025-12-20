class_name FlipSprite
extends Node

@export var sprite: Sprite2D
@export var anim_sprite: AnimatedSprite2D


func flip_sprite_towards(other_position: Vector2) -> void:
	if sprite and sprite.visible:
		_flip_sprite_towards(other_position)
	if anim_sprite and anim_sprite.visible:
		_flip_anim_sprite_towards(other_position)


func _flip_sprite_towards(other_position: Vector2) -> void:
	var new_dir: Vector2 = sprite.global_position.direction_to(other_position)

	if sign(new_dir.x) == 0:
		return

	sprite.flip_h = sign(new_dir.x) == 1


func _flip_anim_sprite_towards(other_position: Vector2) -> void:
	var new_dir: Vector2 = sprite.global_position.direction_to(other_position)

	if sign(new_dir.x) == 0:
		return

	anim_sprite.flip_h = sign(new_dir.x) == -1
