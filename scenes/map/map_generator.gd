class_name MapGenerator extends Node

@export var battle_stats_pool: BattleStatsPool

# 配置游戏地图生成
const X_DIST := 30					# 节点之间宽度距离
const Y_DIST := 25					# 节点之间高度距离
const PLACEMENT_RANDOMNESS := 5		# 节点自身随机偏移

const FLOOR := 15					# 行数
const MAP_WIDTH := 7				# 列数
const PATHS := 6					# 地图最大路径数量

const MONSTER_ROOM_WEIGHT := 10.0	# 怪物房
const SHOP_ROOM_WEIGHT := 2.5		# 商店房
const CAMPFIRE_ROOM_WEIGHT := 4.0	# 篝火房

var random_room_type_weights := {
	Room.Type.MONSTER: 0.0,
	Room.Type.CAMPFIRE: 0.0,
	Room.Type.SHOP: 0.0
}
var random_room_type_total_weight := 0
var map_data: Array[Array]

func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points := _get_random_starting_points()
	# 走六次
	for j in starting_points:
		var current_j := j
		for i in FLOOR - 1:
			current_j = _setup_connection(i, current_j)
	
	battle_stats_pool.setup()
	
	_setup_boss_room()
	_setup_random_room_weights()
	_setup_room_types()

	return map_data


func _generate_initial_grid() -> Array[Array]:
	var result: Array[Array] = []
	for i in FLOOR:
		var adjacent_rooms: Array[Room] = []
		for j in MAP_WIDTH:
			var current_room := Room.new()
			var offset := Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			current_room.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			current_room.row = i
			current_room.column = j
			current_room.next_rooms = []
			# Boss room has a non-random Y
			# 到Boss房的距离多空出一格
			if i == FLOOR - 1:
				current_room.position.y = (i + 1) * -Y_DIST
			adjacent_rooms.append(current_room)
		result.append(adjacent_rooms)
	return result


func _get_random_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int = 0
	while unique_points < 2:
		unique_points = 0
		y_coordinates = []
		for i in PATHS:
			var starting_point := randi_range(0, MAP_WIDTH - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			y_coordinates.append(starting_point)
	return y_coordinates


func _setup_connection(i: int, j: int) -> int:
	var next_room: Room = null
	var current_room = map_data[i][j] as Room
	while not next_room or _would_cross_existing_path(i, j, next_room):
		var randomj := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
		next_room = map_data[i + 1][randomj]
	current_room.next_rooms.append(next_room)
	return next_room.column


func _would_cross_existing_path(i: int, j: int, nextRoom: Room) -> bool:
	if j > 0 and nextRoom.column < j:
		var left_neightbor = map_data[i][j - 1] as Room
		for left_path: Room in left_neightbor.next_rooms:
			if left_path.column > nextRoom.column:
				return true
	if j < MAP_WIDTH - 1 and nextRoom.column > j:
		var right_neightbor = map_data[i][j + 1] as Room
		for right_path: Room in right_neightbor.next_rooms:
			if right_path.column < nextRoom.column:
				return true
	return false


func _setup_boss_room() -> void:
	var middle := floori(MAP_WIDTH * 0.5)
	var boss_room := map_data[FLOOR - 1][middle] as Room
	for j in MAP_WIDTH:
		var current_room = map_data[FLOOR - 2][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms.clear()
			current_room.next_rooms.append(boss_room)
	boss_room.type = Room.Type.BOSS
	boss_room.battle_stats = battle_stats_pool.get_random_battle_for_tier(2)


func _setup_random_room_weights() -> void:
	random_room_type_weights[Room.Type.MONSTER] = MONSTER_ROOM_WEIGHT
	random_room_type_weights[Room.Type.CAMPFIRE] = MONSTER_ROOM_WEIGHT + SHOP_ROOM_WEIGHT
	random_room_type_weights[Room.Type.SHOP] = MONSTER_ROOM_WEIGHT + SHOP_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT
	random_room_type_total_weight = random_room_type_weights[Room.Type.SHOP]


func _setup_room_types() -> void:
	# first floor is always a battle room
	for room: Room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(0)

	# 9th floor is always a treasure room
	for room: Room in map_data[ceili(FLOOR * 0.5)]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.TREASURE

	# last floor before the boss is always a campfire room
	for room: Room in map_data[FLOOR - 2]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.CAMPFIRE
	
	# rest of rooms
	for current_floor in map_data:
		for room: Room in current_floor:
			for next_room: Room in room.next_rooms:
				if next_room.type == Room.Type.NOT_ASSIGNED:
					_set_room_randomly(next_room)


func _set_room_randomly(room_to_set: Room) -> void:
	var campfire_below_4 := true
	var consecutive_campfire := true
	var consecutive_shop := true
	var campfire_on_third_last_layer := true # 因为倒数第二层必为篝火，所以倒数第三层不能是篝火
	
	var type_candidate: Room.Type
	while campfire_below_4 or consecutive_campfire or consecutive_shop or campfire_on_third_last_layer:
		type_candidate = _get_random_room_type_by_weight()
		var is_campfire := type_candidate == Room.Type.CAMPFIRE
		var has_campfire_parent := _room_has_parent_of_type(room_to_set, Room.Type.CAMPFIRE)
		var is_shop := type_candidate == Room.Type.SHOP
		var has_shop_parent := _room_has_parent_of_type(room_to_set, Room.Type.SHOP)
		campfire_below_4 = is_campfire and room_to_set.row < 3
		consecutive_campfire = is_campfire and has_campfire_parent
		consecutive_shop = is_shop and has_shop_parent
		campfire_on_third_last_layer = is_campfire and room_to_set.row == FLOOR - 3
	room_to_set.type = type_candidate
	if type_candidate == Room.Type.MONSTER:
		var tier_for_monster_rooms = 1 if  room_to_set.row > 2 else 0
		room_to_set.battle_stats = battle_stats_pool.get_random_battle_for_tier(tier_for_monster_rooms)


func _room_has_parent_of_type(room: Room, type: Room.Type) -> bool:
	if room.row == 0: return false
	var parent_start_column = clampi(room.column - 1, 0, MAP_WIDTH - 1)
	var parent_end_column = clampi(room.column + 1, 0, MAP_WIDTH - 1)
	for j in range(parent_start_column, parent_end_column + 1):
		var p = map_data[room.row - 1][j] as Room
		if p.next_rooms.has(room) and p.type == type:
			return true
	return false


func _get_random_room_type_by_weight() -> Room.Type:
	var roll := randf_range(0.0, random_room_type_total_weight)
	for type: Room.Type in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
	return Room.Type.MONSTER # never happen
