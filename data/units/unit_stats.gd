class_name UnitStats
extends Resource

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
}
enum Team {
	PLAYER,
	ENEMY,
}

const RARITY_COLORS = {
	Rarity.COMMON: Color("124a2e"), # 深绿色
	Rarity.UNCOMMON: Color("1c527c"), # 深蓝色
	Rarity.RARE: Color("ab0979"), # 紫色
	Rarity.LEGENDARY: Color("ea940b"), # 橙色
}

const TEAM_SPRITESHEET = {
	Team.PLAYER: preload("res://assets/sprites/rogues.png"),
	Team.ENEMY: preload("res://assets/sprites/monsters.png"),
}

const MOVE_ONE_TILE_SPEED := 1.0 # 移动一格所需的时间（秒）

@export var name: String

@export_category("Data")
@export var rarity: Rarity
@export var gold_cost := 1
@export_range(1, 3) var tier := 1:
	set = _set_tier
@export var traits: Array[Trait]
@export var pool_count := 5

@export_category("Visuals")
@export var skin_coordinates: Vector2i
@export var custom_sprite_frames: SpriteFrames # Samurai 这种特殊英雄用这个 (可选)
@export var visual_offset: Vector2 = Vector2.ZERO

@export_category("Battle")
@export var team: Team


func get_combined_unit_count() -> int:
	return 3 ** (tier - 1)


func get_gold_value() -> int:
	return gold_cost * get_combined_unit_count()


func _to_string() -> String:
	return name


func _set_tier(value: int):
	tier = value
	emit_changed()
