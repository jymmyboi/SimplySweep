extends Node2D
@onready var tilemap = $TileMapLayer
@onready var time = $TimeLabel
@export var mine_amount: int
var rng = RandomNumberGenerator.new()
var mines = PackedVector2Array()
var map_bounds = Vector2i(9,9)
var visited = {}
var revealed = []
var win_count
var time_passed = 0

func _ready() -> void:
	var rand_x
	var rand_y
	var mine_coords
	var i = 0
	while i < mine_amount:
		rand_x = rng.randi_range(0,9)
		rand_y = rng.randi_range(0,9)
		mine_coords = Vector2i(rand_x,rand_y)
		if mines.has(mine_coords):
			continue
		else:
			mines.append(mine_coords)
			i += 1
	print(mines)
	win_count = (map_bounds.x + 1) * (map_bounds.y + 1) - mine_amount
	print(win_count)
	time.text = str(time_passed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_select_tiles(event.position, event.button_index)



func _select_tiles(event_pos, event_button_index) -> void:
	var local_mouse_pos = to_local(event_pos)
	var tile_pos = tilemap.local_to_map(local_mouse_pos)
	
	if !_tile_valid_check(tile_pos):
		return	
		
	var mine_count = _calc_mines(tile_pos)
	
	if mine_count == 0:
		_fill_flood(tile_pos)
	elif event_button_index == MOUSE_BUTTON_RIGHT:
		_set_tile_number(tile_pos, 10)
	else:
		_set_tile_number(tile_pos, mine_count)
	print(revealed.size())
	
	if revealed.size() == win_count:
		game_win()


func _set_tile_number(tile_pos, mine_num):
	if !revealed.has(tile_pos) and mine_num < 9:  # Only add if not already revealed
		revealed.append(tile_pos)
	match mine_num:
		0:
			tilemap.set_cell(tile_pos, 1, Vector2i(0,0))
		1:
			tilemap.set_cell(tile_pos, 1, Vector2i(2,0))
		2:
			tilemap.set_cell(tile_pos, 1, Vector2i(2,1))
		3:
			tilemap.set_cell(tile_pos, 1, Vector2i(3,0))
		4:
			tilemap.set_cell(tile_pos, 1, Vector2i(3,1))
		5:
			tilemap.set_cell(tile_pos, 1, Vector2i(4,0))
		6:
			tilemap.set_cell(tile_pos, 1, Vector2i(4,1))
		7:
			tilemap.set_cell(tile_pos, 1, Vector2i(5,0))
		8:
			tilemap.set_cell(tile_pos, 1, Vector2i(5,1))
		9:
			tilemap.set_cell(tile_pos, 1, Vector2i(1,0)) #has mine
			get_tree().change_scene_to_file("res://game_over_screen.tscn")
		10:
			tilemap.set_cell(tile_pos, 1, Vector2i(0,1)) #right click



func _calc_mines(tile_pos) -> int:
	if mines.has(tile_pos):
		return 9

	var mine_total = 0
	var tile_positions = PackedVector2Array([
	Vector2i(tile_pos.x, tile_pos.y - 1), #top
	Vector2i(tile_pos.x, tile_pos.y + 1), #bottom
	Vector2i(tile_pos.x - 1, tile_pos.y), #left
	Vector2i(tile_pos.x + 1, tile_pos.y), #right
	Vector2i(tile_pos.x - 1, tile_pos.y - 1), #top left
	Vector2i(tile_pos.x + 1, tile_pos.y - 1), #top right
	Vector2i(tile_pos.x - 1, tile_pos.y + 1), #bottom left
	Vector2i(tile_pos.x + 1, tile_pos.y + 1) #bottom right
	])
	
	for item in tile_positions:
		if mines.has(item):
			mine_total += 1
	
	return mine_total



func _tile_valid_check(tile_pos) -> bool:
	return tile_pos.x >= 0 and tile_pos.x <= map_bounds.x and tile_pos.y >= 0 and tile_pos.y <= map_bounds.y



func _fill_flood(tile_pos):
	var stack = [tile_pos]

	while stack.size() > 0:
		var current = stack.pop_back()
		if !_tile_valid_check(current) or visited.has(current):
			continue
		visited[current] = true
		
		var mine_count = _calc_mines(current)
		_set_tile_number(current, mine_count)
		
		if mine_count == 0:
			for offset in [
				Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
				Vector2i(0, -1),              Vector2i(0, 1),
				Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)
			]:
				var neighbour = current + offset
				if !visited.has(neighbour):
					stack.append(neighbour)


func _on_timer_timeout() -> void:
	time_passed += 1
	time.text = str(time_passed)

func game_win() -> void:
	GameState.time_passed = time_passed
	get_tree().change_scene_to_file("res://win_screen.tscn")
