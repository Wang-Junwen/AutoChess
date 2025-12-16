class_name BattleUnit
extends Area2D

@export var stats: UnitStats:
	set = _set_stats

@onready var skin: PackedSprite2D = $Visuals/Skin
@onready var custom_skin: AnimatedSprite2D = $Visuals/CustomSkin
@onready var health_bar := $HealthBar
@onready var mana_bar := $ManaBar
@onready var tier_icon: TierIcon = $TierIcon
@onready var unit_ai: UnitAI = $UnitAI
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var use_custom_animation: bool = false


func _set_stats(value: UnitStats) -> void:
	stats = value

	if not stats or not is_instance_valid(tier_icon):
		return

	stats = value.duplicate()
	collision_layer = stats.team + 1

	tier_icon.stats = stats
	health_bar.stats = stats
	mana_bar.stats = stats
	health_bar.show()
	mana_bar.show()

	_set_skin()
	play_idle()


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
