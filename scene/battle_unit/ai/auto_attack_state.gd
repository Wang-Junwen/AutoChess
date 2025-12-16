class_name AutoAttackState
extends State

var actor_unit: BattleUnit
var target: BattleUnit
var timer: Timer # 用于攻击间隔

func _init(new_actor: Node, current_target: BattleUnit) -> void:
	super._init(new_actor)
	target = current_target


func enter() -> void:
	actor_unit = actor as BattleUnit
	print("AutoAttackState: Entered auto attack state for ", actor_unit.name, " targeting ", target.name)
	_perform_attack()

func exit() -> void:
	if timer:
		timer.queue_free()


func _perform_attack() -> void:
	if not is_instance_valid(target):
		# 目标死亡逻辑（切换回 Chase 或 Idle，这里暂时略过）
		return
	# 1. 播放攻击动画
	actor_unit.play_attack()
	# 2. 等待攻击前摇/动画结束 (简单起见，这里等待固定时间或动画时长)
	# 获取动画时长（需要在 BattleUnit 实现 get_attack_duration）
	# 或者简单等待 0.5秒
	# await actor_unit.get_tree().create_timer(0.5).timeout
	# # 3. 造成伤害 (假设 BattleUnit 有 take_damage 方法)
	# if is_instance_valid(target):
	# 	target.take_damage(actor_unit.stats.damage) # 需确认数据结构
	# 4. 攻击冷却 (Cooldown)
	await actor_unit.get_tree().create_timer(1.0).timeout # 攻速 1.0
	# 5. 循环
	_perform_attack()
