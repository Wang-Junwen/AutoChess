class_name UnitCombiner
extends Node

@export var buffer_timer: Timer
@export var combine_sound: AudioStream

var queued_updates := 0
var tween: Tween


func _ready() -> void:
	buffer_timer.timeout.connect(_on_buffer_timer_timeout)


func queue_unit_combination_update() -> void:
	buffer_timer.start()


func _update_unit_combinations(tier: int) -> void:
	var groups := _group_units_in_tier_by_name(tier)
	var triplets: Array[Array] = _get_triplets_from_groups(groups)

	if triplets.is_empty():
		_on_units_combined(tier)
		return

	tween = create_tween()
	for combination in triplets:
		tween.tween_callback(_combine_units.bind(combination[0], combination[1], combination[2]))
		tween.tween_interval(UnitAnimations.COMBINE_ANIM_LENGTH)

	tween.finished.connect(_on_units_combined.bind(tier), CONNECT_ONE_SHOT)


func _group_units_in_tier_by_name(tier: int) -> Dictionary:
	var groups := { }
	var units := get_tree().get_nodes_in_group("units")
	units = units.filter(func(unit: Unit) -> bool: return unit.stats.tier == tier)
	for unit: Unit in units:
		var u_name = unit.stats.name
		if groups.has(u_name):
			groups[u_name].append(unit)
		else:
			groups[u_name] = [unit]
	return groups


# 返回所有的三胞胎数组 [[a, a, a], [a, a, a], [b, b, b]...] 用于升级
func _get_triplets_from_groups(groups: Dictionary) -> Array[Array]:
	var upgrades: Array[Array] = []

	for unit_name in groups:
		var cur_units: Array = groups[unit_name]
		while cur_units.size() >= 3:
			var combination := [cur_units[0], cur_units[1], cur_units[2]]
			upgrades.append(combination)
			cur_units = cur_units.slice(3)

	return upgrades


func _on_buffer_timer_timeout() -> void:
	queued_updates += 1

	if not tween or not tween.is_running():
		_update_unit_combinations(1)


func _combine_units(unit1: Unit, unit2: Unit, unit3: Unit) -> void:
	unit1.stats.tier += 1
	unit2.remove_from_group("units")
	unit3.remove_from_group("units")
	unit2.animations.play_combine_animation(unit1.global_position + Arena.QUARTER_CELL_SIZE)
	unit3.animations.play_combine_animation(unit1.global_position + Arena.QUARTER_CELL_SIZE)
	SFXPlayer.play(combine_sound)


func _on_units_combined(tier: int) -> void:
	if tier == 1:
		_update_unit_combinations(2)
	else:
		queued_updates -= 1
		if queued_updates >= 1:
			_update_unit_combinations(1)
