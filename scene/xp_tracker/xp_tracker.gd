class_name XPTracker
extends VBoxContainer

@export var player_stats: PlayerStats

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var xp_label: Label = %XPLabel
@onready var level_label: Label = %LevelLabel


func _ready():
	player_stats.changed.connect(_on_player_stats_changed)
	_on_player_stats_changed()
	

func _on_player_stats_changed():
	if player_stats.level < 10:
		_set_xp_bar_values()
	else:
		_set_max_level_values()

	level_label.text = "lvl: %s" % player_stats.level


func _set_xp_bar_values():
	# 将xp转换为float，以便进行除法运算
	var xp_req: float = player_stats.get_currentj_xp_requirement()
	xp_label.text = "%s/%s" % [player_stats.xp, int(xp_req)]
	progress_bar.value = player_stats.xp / xp_req * 100


func _set_max_level_values():
	xp_label.text = "MAX"
	progress_bar.value = 100
