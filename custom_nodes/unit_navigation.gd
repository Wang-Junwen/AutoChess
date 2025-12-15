extends Node

signal path_calculated(points: Array[Vector2i], moving_unit: BattleUnit)

var battle_grid: UnitGrid
var game_area: PlayArea
var astar_grid: AStarGrid2D
var full_grid_region: Rect2i


func initialize(grid: UnitGrid, area: PlayArea) -> void:
	battle_grid = grid
	game_area = area

	full_grid_region = Rect2i(Vector2i.ZERO, battle_grid.size)
	astar_grid = AStarGrid2D.new()
	astar_grid.region = full_grid_region
	astar_grid.cell_size = Arena.CELL_SIZE
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

	battle_grid.unit_grid_changed.connect(update_occupied_tiles)


# 更新被占据的瓦片
# 该函数用于更新A*网格中被占据的瓦片状态
func update_occupied_tiles() -> void:
	# 首先将整个网格区域清空
	astar_grid.fill_solid_region(full_grid_region, false)
	# 遍历战斗网格中所有被占据的瓦片
	for id: Vector2i in battle_grid.get_all_occupied_tiles():
		# 将这些被占据的瓦片设置为不可通过（solid）
		astar_grid.set_point_solid(id)


# 计算路径
# 该函数用于计算从起点到终点的路径，返回下一个目标全局坐标
func get_next_position(moving_unit: BattleUnit, target_unit: BattleUnit) -> Vector2:
	var unit_tile := game_area.get_tile_from_global(moving_unit.global_position)
	var target_tile := game_area.get_tile_from_global(target_unit.global_position)

	# 第一步： 将当前单位坐在瓦片移除障碍物效果, 计算路径
	astar_grid.set_point_solid(unit_tile, false)
	var path := astar_grid.get_id_path(unit_tile, target_tile, true)
	path_calculated.emit(path, moving_unit)

	# 第二步：如果当前单位四周没有格子时，就停在原地，并且将当前单位坐在瓦片重新设置为障碍物效果
	if path.size() == 1 and path[0] == unit_tile:
		astar_grid.set_point_solid(unit_tile, true)
		return Vector2(-1, -1)

	# 第三步：有有效的路径时，就移动到下一个瓦片，并移除原来位置，并设置新的位置为障碍物效果
	var next_tile := path[1]
	battle_grid.move_unit(unit_tile, next_tile)
	# battle_grid的unit_grid_changed会触发update_occupied_tiles，但是这里还是手动修改一下
	astar_grid.set_point_solid(unit_tile, true)

	return game_area.get_global_from_tile(next_tile)
