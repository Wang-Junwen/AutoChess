class_name ChaseState
extends State

signal target_reached(target: BattleUnit)
signal stuck

var actor_unit: BattleUnit
var tween: Tween
var target: BattleUnit


func enter() -> void:
	actor_unit = actor as BattleUnit
	_set_target(actor_unit.stats.team)


func exit() -> void:
	pass


func _set_target(team: UnitStats.Team) -> void:
	if team == UnitStats.Team.PLAYER:
		target = actor_unit.get_tree().get_nodes_in_group("enemy_units").pick_random()
	else:
		target = actor_unit.get_tree().get_nodes_in_group("player_units").pick_random()


func chase() -> void:
	if tween and tween.is_running():
		return

	var new_post := UnitNavigation.get_next_position(actor_unit, target)
	if new_post == Vector2(-1, -1):
		if _has_target_in_range():
			_end_chase()
		else:
			stuck.emit()
		return

	tween = actor_unit.create_tween()
	tween.tween_callback(actor_unit.play_move)
	# TODO: 之后每个单位可能会有不同的移动速度
	tween.tween_property(actor_unit, "global_position", new_post, UnitStats.MOVE_ONE_TILE_SPEED)
	tween.finished.connect(
		func():
			tween.kill() 

			if _has_target_in_range():
				_end_chase()
			else:
				chase()
	)


func _end_chase() -> void:
	target_reached.emit(target)


func _has_target_in_range() -> bool:
	return (target.global_position - actor_unit.global_position).length() <= Arena.CELL_SIZE.x + 3
