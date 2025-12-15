class_name XPButton
extends Button

@export var player_stats: PlayerStats
@export var gold_cost: int = 4
@export var xp_provided: int = 4
@export var xp_sound: AudioStream

@onready var vbox_container: VBoxContainer = $VBoxContainer
@onready var xplabel: Label = %XPLabel
@onready var gold_label: Label = %GoldLabel

func _ready() -> void:
	xplabel.text = "+%dXP" % xp_provided
	gold_label.text = str(gold_cost)
	player_stats.changed.connect(_on_player_stats_changed)
	_on_player_stats_changed()


func _on_player_stats_changed() -> void:
	var has_enough_gold := player_stats.gold >= gold_cost
	var level_max := player_stats.level >= PlayerStats.MAX_LEVEL
	disabled = not has_enough_gold or level_max

	if has_enough_gold and not level_max:
		vbox_container.modulate.a = 1.0
	else:
		vbox_container.modulate.a = 0.5


func _on_pressed() -> void:
	player_stats.gold -= gold_cost
	player_stats.add_xp(xp_provided)
	SFXPlayer.play(xp_sound)
