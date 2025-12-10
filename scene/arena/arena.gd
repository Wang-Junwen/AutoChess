class_name Arena
extends Node2D

# 每个格子的尺寸，以及其一半和四分之一尺寸的常量定义
const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)
const QUARTER_CELL_SIZE := Vector2(8, 8)

@onready var unit_spawner: UnitSpawner = $UnitSpawner
@onready var unit_mover: UnitMover = $UnitMover

func _ready():
	# 连接单位生成器与单位移动器的信号
	unit_spawner.unit_spawned.connect(unit_mover.setup_unit)
