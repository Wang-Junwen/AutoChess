class_name UnitStats
extends Resource

signal health_reached_zero
signal mana_bar_fill

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

const TARGET := {
	Team.PLAYER: "enemy_units",
	Team.ENEMY: "player_units",
}

const TEAM_SPRITESHEET = {
	Team.PLAYER: preload("res://assets/sprites/rogues.png"),
	Team.ENEMY: preload("res://assets/sprites/monsters.png"),
}

const MAX_ATTACK_RANGE := 5
const MANA_PER_ATTACK := 10
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
@export var max_health: Array[int]
@export var max_mana: int
@export var staring_mana: int
@export var attack_damage: Array[int]
@export var ability_power: int # 法术强度
@export var attack_speed: float # 每秒攻击次数
@export var armor: int # 物理抗性
@export var magic_resist: int # 魔法抗性
@export_range(1, MAX_ATTACK_RANGE) var attack_range: int

var health: int:
	set = _set_health
var mana: int:
	set = _set_mana


func reset_health() -> void:
	health = get_max_health()


func reset_mana() -> void:
	mana = staring_mana


func get_combined_unit_count() -> int:
	return 3 ** (tier - 1)


func get_gold_value() -> int:
	return gold_cost * get_combined_unit_count()


func get_max_health() -> int:
	return max_health[tier - 1]


func get_attack_damage() -> int:
	return attack_damage[tier - 1]


func get_time_between_attacks() -> float:
	return 1.0 / attack_speed


func is_melee() -> bool:
	return attack_range == 1


func _set_health(value: int) -> void:
	health = clamp(value, 0, get_max_health())
	emit_changed()

	if health <= 0:
		health_reached_zero.emit()


func _set_mana(value: int) -> void:
	mana = clamp(value, 0, max_mana)
	emit_changed()

	if mana >= max_mana and max_mana > 0:
		mana_bar_fill.emit()


func _to_string() -> String:
	return name


func _set_tier(value: int):
	tier = value
	emit_changed()
