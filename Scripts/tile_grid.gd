extends Node3D

signal added_tiles

const TILE = preload("res://Scenes/Tile.tscn")

const top_radius : float = 1
const x_spacing : float = (top_radius * 2) * 1.5
const y_spacing : float = ((cos(deg_to_rad(30)) * top_radius) * 2)

@export var _new_width: int
@export var _new_depth: int

var astar = AStar3D.new()
var tile_positions : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var adjusted_width = _new_width + ((_new_width + 1) % 2)
	var adjusted_depth = _new_depth + ((_new_depth + 1) % 2)
	var this_position : Vector3
	var this_lookup_position : Vector2i
	tile_positions = {}
	var id_counter := 0
	for row in range(adjusted_depth):
		var row_mult : float = (row - floor(float(adjusted_depth) / 2))
		for col in range(adjusted_width):
			var col_mult = (col - floor(float(adjusted_width) / 2))
			var positionX : float = (x_spacing) * col_mult
			var positionY : float = y_spacing * row_mult
			var grid_tile = TILE.instantiate()
			this_position = Vector3(positionX, 0, positionY)
			this_lookup_position = Vector2i(int(col_mult * 2),int(row_mult * 2))
			tile_positions[this_lookup_position] = {"astar_id": id_counter,"tile_id": grid_tile.get_instance_id(),"connections":[]}
			astar.add_point(id_counter,this_position)
			grid_tile.astar_id = id_counter
			grid_tile.lookup = this_lookup_position
			id_counter += 1
			add_child(grid_tile)
			grid_tile.position = this_position
			if not (col == adjusted_width - 1):
				var bottom_tile = TILE.instantiate()
				this_position = Vector3(positionX + (x_spacing * 0.5), 0, positionY + (y_spacing * 0.5))
				this_lookup_position = Vector2i(int(col_mult * 2) + 1,int(row_mult * 2) + 1)
				tile_positions[this_lookup_position] = {"astar_id": id_counter,"tile_id": bottom_tile.get_instance_id(),"connections":[]}
				astar.add_point(id_counter,this_position)
				bottom_tile.astar_id = id_counter
				bottom_tile.lookup = this_lookup_position
				id_counter += 1
				add_child(bottom_tile)
				bottom_tile.position = this_position
				if row == 0:
					var top_tile = TILE.instantiate()
					this_position = Vector3(positionX + (x_spacing * 0.5), 0, positionY - (y_spacing * 0.5))
					this_lookup_position = Vector2i(int(col_mult * 2) + 1,int(row_mult * 2) - 1)
					tile_positions[this_lookup_position] = {"astar_id": id_counter,"tile_id": top_tile.get_instance_id(),"connections":[]}
					astar.add_point(id_counter,this_position)
					top_tile.astar_id = id_counter
					top_tile.lookup = this_lookup_position
					id_counter += 1
					add_child(top_tile)
					top_tile.position = this_position

	var hex_directions = [
		Vector2i(1,1),
		Vector2i(1,-1),
		Vector2i(0,2),
		Vector2i(-1,1),
		Vector2i(-1,-1),
		Vector2i(0,-2)
	]

	this_position = astar.get_point_position(0)

	for tile in tile_positions:
		for dir in hex_directions:
			var neighbor = tile + dir
			if tile_positions.has(neighbor):
				instance_from_id(tile_positions[tile].tile_id).astar_connections.append(tile_positions[neighbor].astar_id)
				astar.connect_points(tile_positions[tile].astar_id,tile_positions[neighbor].astar_id)
				tile_positions[tile].connections.append(tile_positions[neighbor].astar_id)

	var min_bound = Vector3.ZERO
	var max_bound = Vector3.ZERO
	for obj in get_children():
		min_bound = min_bound.min(obj.global_position)
		max_bound = max_bound.max(obj.global_position)
	added_tiles.emit(min_bound,max_bound)

func _input(_event):
	if Input.is_action_just_pressed("Quick Select 2"):
		pass
		# var test_array = get_location_astar_connections(Vector3(0.0, 0.0, 0.0),3,"Tile")
		# print(test_array)
		# (-8.5, 0.0, 0.866025) .5, -2.83
		# (-7.0, 0.0, 1.732051) 1, -2.33
		# (-2.5, 0.0, 4.330127) 2.5, -0.83
		# (-1.0, 0.0, 6.928203) 4, -0.33
		# (3.5, 0.0, -9.526279)
		# (5.5, 0.0, -9.526279)
		# (3.5, 0.0, -7.794229)
		# (5.5, 0.0, -7.794229) -4.5, 1.83
		# (2.0, 0.0, -8.660254)
		# (4.0, 0.0, -8.660254)



func find_closest_tile(pos: Vector3) -> int:
	var closest_id = -1
	var closest_dist = INF
	for tile_pos in tile_positions.keys():
		var dist = pos.distance_to(tile_pos)
		if dist < 0.01 and dist < closest_dist: # small tolerance
			closest_dist = dist
			closest_id = tile_positions[tile_pos].astar_id
	return closest_id

func find_nest_location():
	var possible_arr = []
	for child in get_children():
		if not child.nest_spawn_prevented and not [_new_width,_new_width*-1].has(child.lookup[0]) and not [(_new_depth+1),(_new_depth+1)*-1].has(child.lookup[1]):
			# print(child.lookup)
			possible_arr.append(child)
	var nest_tile = possible_arr[randi_range(0,len(possible_arr) - 1)]
	nest_tile.state_machine.set_state("nest")
	return nest_tile

func find_nav_path(start_v:Vector3,end_v:Vector3):
	var start = astar.get_closest_point(start_v)
	var end = astar.get_closest_point(end_v)
	if start and end:
		var path = astar.get_id_path(start,end,false)
		if path.size() > 0:
			var path_removed = path.slice(1,-1)
			var return_path = [astar.get_point_position(path[0]) + Vector3(0,0.5,0)]
			for point_id in path_removed:
				var full_conn = true
				var connections = get_tile_dict_from_astar_id(point_id).get("connections")
				for conn in connections:
					var connected = (astar.are_points_connected(conn,point_id,false) and astar.are_points_connected(point_id,conn,false))
					if not connected:
						full_conn = false
				if not full_conn:
					return_path.append(astar.get_point_position(point_id) + Vector3(0,0.5,0))
			return_path.append(astar.get_point_position(path[-1]) + Vector3(0,0.5,0))
			return return_path
		else:
			return []
	else:
		return []

func update_all_astar_weights():
	for this_position in tile_positions:
		var tile = tile_positions[this_position]
		var neighbors = tile.get("connections")
		var id_conn_count = 0

		for neighbor in neighbors:
			if astar.are_points_connected(tile.astar_id,neighbor,false):
				id_conn_count += 1

		var weighted_count = (float(id_conn_count)/float(neighbors.size())) * 6.0

		astar.set_point_weight_scale(tile.astar_id,4/weighted_count)
		


func get_tile_dict_from_astar_id(target_id: int) -> Dictionary:
	for coord in tile_positions.keys():
		var tile_data = tile_positions[coord]
		if tile_data.get("astar_id") == target_id:
			return tile_data
	return {"connections": []}

func clear_connections(location:Vector3):
	var this_id = tile_positions[location].astar_id
	for conn in astar.get_point_connections(this_id):
		astar.disconnect_points(this_id,conn)

func get_location_astar_connections(target_location:Vector3,levels:int,placement_group:String) -> Array[Dictionary]:
	var new_tile_array: Array[Dictionary] = []
	var this_tile_id = null
	if placement_group == "Snap Point":
		var approx_row = target_location.z / y_spacing
		var approx_col = target_location.x / x_spacing
		var this_col_pos = approx_col - int(approx_col)
		var neighbor_array: Array
		if in_ranges(this_col_pos, [
			Vector2(0.8, 0.9),
			Vector2(0.3, 0.4),
			Vector2(-0.2, 0.1),
			Vector2(-0.7, -0.6)
		]):
			var x_index = floor(approx_col * 2)
			var y_index = round(approx_row * 2)
			neighbor_array = [
				Vector2i(x_index,y_index),
				Vector2i(x_index + 1,y_index + 1),
				Vector2i(x_index + 1,y_index - 1)
			]
			# add_debug_sphere(target_location,Color.GREEN)
		else:
			var x_index = ceil(approx_col * 2)
			var y_index = round(approx_row * 2)
			neighbor_array = [
				Vector2i(x_index,y_index),
				Vector2i(x_index - 1,y_index + 1),
				Vector2i(x_index - 1,y_index - 1)
			]
			# add_debug_sphere(target_location,Color.RED)
		for neighbor in neighbor_array:
			if tile_positions.has(neighbor):
				new_tile_array.append(tile_positions[neighbor])
				# add_debug_sphere(instance_from_id(tile_positions[neighbor].tile_id).global_position,Color.BLUE)
	elif placement_group == "Tile":
		this_tile_id = astar.get_closest_point(target_location)
		var this_connections = get_tile_dict_from_astar_id(this_tile_id).get("connections")
		for neighbor in this_connections:
			new_tile_array.append(get_tile_dict_from_astar_id(neighbor))
			# add_debug_sphere(astar.get_point_position(neighbor),Color.BLUE)
	var recent_tile_array = new_tile_array.duplicate()
	for i in range(levels-1):
		var very_recent_tile_array = []
		for tile in recent_tile_array:
			for conn in get_tile_dict_from_astar_id(tile.astar_id).get("connections"):
				var this_tile_dict = get_tile_dict_from_astar_id(conn)
				if not new_tile_array.has(this_tile_dict) and not this_tile_dict.astar_id == this_tile_id:
					very_recent_tile_array.append(this_tile_dict)
					new_tile_array.append(this_tile_dict)
					# add_debug_sphere(astar.get_point_position(conn),Color.VIOLET)
		recent_tile_array = very_recent_tile_array.duplicate()
	return new_tile_array

func get_tile_angle(target_location:Vector3) -> bool:
	var tile_angle: bool = true

	var approx_col = target_location.x / x_spacing
	var this_col_pos = approx_col - int(approx_col)
	if not in_ranges(this_col_pos, [
		Vector2(0.8, 0.9),
		Vector2(0.3, 0.4),
		Vector2(-0.2, 0.1),
		Vector2(-0.7, -0.6)
	]):
		tile_angle = false
		
	return tile_angle

func in_ranges(value: float, ranges: Array) -> bool:
	for r in ranges:
		if value > r.x and value < r.y:
			return true
	return false

func add_debug_sphere(target_location: Vector3,color: Color) -> void:
	var new_mesh = MeshInstance3D.new()
	new_mesh.position = target_location
	new_mesh.mesh = SphereMesh.new()
	var new_material = StandardMaterial3D.new()
	new_mesh.material_override = new_material
	new_material.albedo_color = color
	add_child(new_mesh)
