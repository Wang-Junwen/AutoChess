class_name AutoAttackState
extends State

var actor_unit: BattleUnit
var target: BattleUnit


func _init(new_actor: Node, current_target: BattleUnit) -> void:
	super._init(new_actor)
	target = current_target


func enter() -> void:
	actor_unit = actor as BattleUnit
	print("AutoAttackState: Entered auto attack state for ", actor_unit.name, " targeting ", target.name)
