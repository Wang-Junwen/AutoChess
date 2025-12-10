class_name UnitSpawner
extends Node

signal unit_spawned(unit: Unit)

const UNIT = preload("res://scene/unit/unit.tscn")

@export var bench: PlayArea
@export var game_area: PlayArea

func _ready() -> void:
	var robin := preload("res://data/units/robin.tres")
	var tween := create_tween()

	for i in 15:
		tween.tween_callback(spawn_unit.bind(robin))
		tween.tween_interval(0.5)


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

	var unit := UNIT.instantiate()
	var tile := area.unit_grid.get_first_empty_tile()
	unit.stats = unit_stats
	area.unit_grid.add_unit(tile, unit)
	area.unit_grid.add_child(unit)
	unit.global_position = area.get_global_from_tile(tile) - Arena.HALF_CELL_SIZE
	unit_spawned.emit(unit)
