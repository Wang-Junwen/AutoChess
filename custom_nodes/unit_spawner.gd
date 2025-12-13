class_name UnitSpawner
extends Node

signal unit_spawned(unit: Unit)

@export var bench: PlayArea
@export var game_area: PlayArea

@onready var unit_scene_spawner: SceneSpawner = $SceneSpawner


func _get_first_available_area() -> PlayArea:
	if not bench.unit_grid.is_grid_full():
		return bench
	if not game_area.unit_grid.is_grid_full():
		return game_area
	return null


func spawn_unit(unit_stats: UnitStats) -> void:
	var area := _get_first_available_area()
	# TODO: 之后改为错误弹窗
	assert(area, "No available area to spawn unit")

	var unit := unit_scene_spawner.spawn_scene(area.unit_grid) as Unit
	var tile := area.unit_grid.get_first_empty_tile()
	unit.stats = unit_stats
	area.unit_grid.add_unit(tile, unit)
	unit.global_position = area.get_global_from_tile(tile) - Arena.HALF_CELL_SIZE
	unit_spawned.emit(unit)
