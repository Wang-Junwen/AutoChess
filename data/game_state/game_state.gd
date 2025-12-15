class_name GameState
extends Resource

enum Phase {
	PREPARATION,
	BATTLE,
}

@export var current_phase: Phase:
	set(value):
		current_phase = value
		changed.emit()


func start_battle() -> void:
	current_phase = Phase.BATTLE


func is_battling() -> bool:
	return current_phase == Phase.BATTLE
