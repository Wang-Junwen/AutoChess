class_name UnitGrid
extends Node2D

# 当单位在网格上的状态发生变化时发出信号
signal unit_grid_changed()


# 网格尺寸（例如 Vector2i(8, 8) 表示 8x8 的棋盘）
# 用于判断坐标是否越界
@export var size: Vector2i

# 存储网格数据的字典: { Vector2i: Unit }
# key: 网格坐标, value: Unit 实例
var units: Dictionary[Vector2i, Unit]


func _ready() -> void:
	for i in size.x:
		for j in size.y:
			units[Vector2i(i, j)] = null

# --- 查询方法 ---


# 检查是否被占用
func is_tile_occupied(tile: Vector2i) -> bool:
	return units[tile] != null


# 检查网格是否填满
func is_grid_full() -> bool:
	return units.keys().all(is_tile_occupied)


# 获取第一个空格子
func get_first_empty_tile() -> Vector2i:
	for tile in units:
		if not is_tile_occupied(tile):
			return tile
	return Vector2i(-1, -1)


# 获取所有单位
func get_all_units() -> Array:
	var unit_array: Array[Unit] = []
	for unit: Unit in units.values():
		if unit:
			unit_array.append(unit)
	return unit_array


# 检查坐标是否在网格范围内
func is_tile_valid(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.x < size.x and tile.y >= 0 and tile.y < size.y


# 获取指定格子的单位，如果为空或越界则返回 null
func get_unit_at(tile: Vector2i) -> Unit:
	if not is_tile_valid(tile):
		return null
	return units.get(tile)


# 反向查找：根据单位实例查找其坐标
# 如果单位不在网格中，返回 Vector2i.MIN
func get_unit_tile(unit: Unit) -> Vector2i:
	for tile in units:
		if units[tile] == unit:
			return tile
	return Vector2i.MIN

# --- 修改方法 ---


# 将单位放置到指定格子
func add_unit(tile: Vector2i, unit: Unit) -> void:
	if not is_tile_valid(tile):
		push_warning("UnitGrid: Cannot add unit to invalid tile %s (Grid Size: %s)" % [tile, size])
		return

	if is_tile_occupied(tile):
		push_warning("UnitGrid: tile %s is already occupied by %s" % [tile, units[tile]])
		return

	units[tile] = unit
	unit_grid_changed.emit()


# 从网格中移除单位
func remove_unit(tile: Vector2i) -> void:
	var unit = units[tile] as Node
	if not unit:
		return

	units[tile] = null
	unit_grid_changed.emit()
