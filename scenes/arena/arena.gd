class_name Arena
extends Node2D

# 每个格子的尺寸，以及其一半和四分之一尺寸的常量定义
const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)
const QUARTER_CELL_SIZE := Vector2(8, 8)

@export var arena_music_stream: AudioStream
@export var game_state: GameState

@onready var game_area: PlayArea = $GameArea
@onready var battle_unit_grid: UnitGrid = $GameArea/BattleUnitGrid
@onready var sell_portal: SellPortal = $SellPortal
@onready var unit_spawner: UnitSpawner = $UnitSpawner
@onready var unit_mover: UnitMover = $UnitMover
@onready var unit_combiner: UnitCombiner = $UnitCombiner
@onready var shop: Shop = %Shop
@onready var battle_mask: TileMapLayer = $GameArea/BattleMask


func _ready():
	# 连接单位生成器与单位移动器的信号
	unit_spawner.unit_spawned.connect(unit_mover.setup_unit)
	unit_spawner.unit_spawned.connect(sell_portal.setup_unit)
	unit_spawner.unit_spawned.connect(unit_combiner.queue_unit_combination_update.unbind(1))
	shop.unit_bought.connect(unit_spawner.spawn_unit)
	game_state.changed.connect(_update)

	MusicPlayer.play(arena_music_stream)
	UnitNavigation.initialize(battle_unit_grid, game_area)
	_update()


var tween: Tween


func _update():
	if tween:
		tween.kill()

	tween = create_tween().set_parallel(false)

	if game_state.is_battling():
		# 战斗开始：淡出遮罩
		tween.tween_property(battle_mask, "modulate:a", 0.0, 0.3)
		tween.tween_callback(battle_mask.hide)
	else:
		# 准备阶段：淡入遮罩
		battle_mask.show()
		tween.tween_property(battle_mask, "modulate:a", 1.0, 0.3)
