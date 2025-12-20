class_name StuckState
extends State

signal timeout

const STUCK_WAIT_TIME := 0.5

var elasped_time := 0.0


func physics_process(delta: float) -> void:
	elasped_time += delta
	if elasped_time >= STUCK_WAIT_TIME:
		timeout.emit()
