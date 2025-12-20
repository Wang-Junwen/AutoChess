class_name BattleUnit
extends Area2D

@export var stats: UnitStats:
	set = _set_stats

@onready var skin: PackedSprite2D = $Visuals/Skin
@onready var custom_skin: AnimatedSprite2D = $Visuals/CustomSkin
@onready var detect_range: DetectRange = $DetectRange
@onready var hurt_box: HurtBox = $HurtBox
@onready var health_bar := $HealthBar
@onready var mana_bar := $ManaBar
@onready var tier_icon: TierIcon = $TierIcon
@onready var attack_timer: Timer = $AttackTimer
@onready var flip_sprite: FlipSprite = $FlipSprite
@onready var melee_attack: Attack = $MeleeAttack
@onready var target_finder: TargetFinder = $TargetFinder
@onready var unit_ai: UnitAI = $UnitAI
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var use_custom_animation: bool = false


func _ready() -> void:
	hurt_box.hurt.connect(_on_hurt)


# --- 统一动画接口 ---
func play_idle() -> void:
	if use_custom_animation:
		custom_skin.play("idle")
	else:
		animation_player.play("RESET")


func play_move() -> void:
	if use_custom_animation:
		custom_skin.play("move")
	else:
		animation_player.play("move")


func play_attack() -> void:
	if use_custom_animation:
		custom_skin.play("attack")
	else:
		animation_player.play("attack")


func on_attack_finish(callback: Callable) -> void:
	if use_custom_animation:
		custom_skin.animation_finished.connect(callback, CONNECT_ONE_SHOT)
	else:
		animation_player.animation_finished.connect(callback.unbind(1), CONNECT_ONE_SHOT)


# 辅助：获取攻击动画时长（用于攻击节奏控制）
func get_attack_animation_length() -> float:
	if use_custom_animation:
		# 获取 "attack" 动画的帧数 / FPS
		var anim_name = "attack"
		if custom_skin.sprite_frames.has_animation(anim_name):
			var count = custom_skin.sprite_frames.get_frame_count(anim_name)
			var speed = custom_skin.sprite_frames.get_animation_speed(anim_name)
			return count / speed if speed > 0 else 0.2
		return 0.2
	return animation_player.get_animation("attack").length


func _set_stats(value: UnitStats) -> void:
	stats = value

	if not stats or not is_instance_valid(tier_icon):
		return

	stats = value.duplicate()
	# player层级为1，enemy层级为2
	collision_layer = stats.get_self_collision_layer()
	hurt_box.collision_layer = stats.get_self_collision_layer()
	hurt_box.collision_mask = stats.get_target_collision_layer()

	_set_skin()

	melee_attack.spawner.scene = stats.melee_attack
	detect_range.stats = stats
	tier_icon.stats = stats
	health_bar.stats = stats
	mana_bar.stats = stats
	health_bar.show()
	mana_bar.show()
	stats.health_reached_zero.connect(queue_free)


func _set_skin() -> void:
	# 判断是否有专属动画资源
	if stats.custom_sprite_frames:
		use_custom_animation = true

		# 切换显示
		skin.hide()
		custom_skin.show()

		# 配置专属动画
		custom_skin.sprite_frames = stats.custom_sprite_frames
		custom_skin.position = stats.visual_offset # 应用偏移
		custom_skin.flip_h = stats.team != stats.Team.PLAYER

	else:
		use_custom_animation = false

		# 切换显示
		skin.show()
		custom_skin.hide()

		# 配置通用动画
		skin.texture = UnitStats.TEAM_SPRITESHEET[stats.team]
		skin.coordinates = stats.skin_coordinates
		# 进入战斗后，翻转玩家角色面向右方
		skin.flip_h = stats.team == stats.Team.PLAYER

	play_idle()


func _on_hurt(damage: int) -> void:
	stats.health -= damage
