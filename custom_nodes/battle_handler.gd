class_name BattleHandler
extends Node

signal player_won
signal enemy_won

const ZOMBIE_TEST_POSITIONS := [
	Vector2i(8, 1),
	Vector2i(7, 4),
	Vector2i(8, 3),
	Vector2i(9, 5),
	Vector2i(9, 6),
]

const ZOMBIE := preload("res://data/enemy/zombie.tres")

@export var game_state: GameState
@export var game_area: PlayArea
@export var game_area_unit_grid: UnitGrid
@export var battle_unit_grid: UnitGrid

@onready var scene_spawner: SceneSpawner = $SceneSpawner


func _ready() -> void:
	game_state.changed.connect(_on_game_state_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test1"):
		var ai_unit := get_tree().get_nodes_in_group("player_units")[0] as BattleUnit
		ai_unit.unit_ai.enabled = true

	if event.is_action_pressed("test2"):
		var ai_unit := get_tree().get_nodes_in_group("player_units")[1] as BattleUnit
		ai_unit.unit_ai.enabled = true

func _setup_battle_unit(unit_coord: Vector2i, new_unit: BattleUnit) -> void:
	new_unit.global_position = game_area.get_global_from_tile(unit_coord) + Vector2(0, -Arena.QUARTER_CELL_SIZE.y)
	new_unit.tree_exited.connect(_on_battle_unit_died)
	battle_unit_grid.add_unit(unit_coord, new_unit)


func _on_game_state_changed() -> void:
	match game_state.current_phase:
		GameState.Phase.PREPARATION:
			_clean_up_fight()
		GameState.Phase.BATTLE:
			_perpare_fight()


func _clean_up_fight() -> void:
	get_tree().call_group("player_units", "queue_free")
	get_tree().call_group("enemy_units", "queue_free")
	get_tree().call_group("units", "show")


func _perpare_fight() -> void:
	get_tree().call_group("units", "hide")

	for unit_coord: Vector2i in game_area_unit_grid.get_all_occupied_tiles():
		var unit: Unit = game_area_unit_grid.get_unit_at(unit_coord)
		var new_unit := scene_spawner.spawn_scene(battle_unit_grid) as BattleUnit
		new_unit.add_to_group("player_units")
		new_unit.stats = unit.stats
		new_unit.stats.team = UnitStats.Team.PLAYER
		_setup_battle_unit(unit_coord, new_unit)

	for zombie_pos: Vector2i in ZOMBIE_TEST_POSITIONS:
		var new_zombie := scene_spawner.spawn_scene(battle_unit_grid) as BattleUnit
		new_zombie.add_to_group("enemy_units")
		new_zombie.stats = ZOMBIE
		new_zombie.stats.team = UnitStats.Team.ENEMY
		_setup_battle_unit(zombie_pos, new_zombie)


func _on_battle_unit_died() -> void:
	if not get_tree() or not game_state.is_battling():
		return

	if get_tree().get_node_count_in_group("enemy_units") == 0:
		game_state.current_phase = GameState.Phase.PREPARATION
		player_won.emit()

	elif get_tree().get_node_count_in_group("player_units") == 0:
		game_state.current_phase = GameState.Phase.PREPARATION
		enemy_won.emit()
