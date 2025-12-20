class_name TeamSizeUI
extends PanelContainer

@export var player_stast: PlayerStats
@export var arena_grid: UnitGrid

@onready var unit_counter: Label = %UnitCounter
@onready var too_many_unit_icon: TextureRect = %TooManyUnitIcon


func _ready() -> void:
	player_stast.changed.connect(_update)
	arena_grid.unit_grid_changed.connect(_update)
	_update()


func _update() -> void:
	var unit_used := arena_grid.get_all_units().size()
	unit_counter.text = "%s/%s" % [unit_used, player_stast.level]
	too_many_unit_icon.visible = unit_used > player_stast.level
