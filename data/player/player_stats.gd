class_name PlayerStats
extends Resource

const XP_REQUIREMENTS := {
	1: 0,
	2: 2,
	3: 2,
	4: 6,
	5: 10,
	6: 20,
	7: 36,
	8: 48,
	9: 70,
	10: 76,
}

@export_range(0, 99) var gold: int:
	set = _set_gold
@export_range(0, 99) var xp: int:
	set = _set_xp
@export_range(1, 10) var level: int:
	set = _set_level


func get_currentj_xp_requirement() -> int:
	var next_level = clampi(level + 1, 1, 10)
	return XP_REQUIREMENTS[next_level]


func add_xp(value: int) -> void:
	_set_xp(xp + value)


func _set_gold(value: int) -> void:
	gold = value
	emit_changed()


func _set_xp(value: int) -> void:
	xp = value
	emit_changed()

	if level == 10:
		return

	var xp_req: int = get_currentj_xp_requirement()

	while level < 10 and xp >= xp_req:
		xp -= xp_req
		level += 1
		xp_req = get_currentj_xp_requirement()
		emit_changed()


func _set_level(value: int) -> void:
	level = value
	emit_changed()
