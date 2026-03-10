extends Node3D

var mesh_1: Node3D
var mesh_2: Node3D
var mesh_3: Node3D

# var astar : AStar3D = AStar3D.new()
# var location_dict = {
# 	Vector3(-1,0,-1): 1,
# 	Vector3(0,0,-1): 2,
# 	Vector3(1,0,-1): 3,
# 	Vector3(-1,0,0): 4,
# 	Vector3(0,0,0): 5,
# 	Vector3(1,0,0): 6,
# 	Vector3(-1,0,1): 7,
# 	Vector3(0,0,1): 8,
# 	Vector3(1,0,1): 9,
# }

# var connection_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh_1 = Node3D.new()
	mesh_2 = Node3D.new()
	mesh_3 = Node3D.new()

	add_child(mesh_1)


# func astar_test() -> void:
# 	for loc in location_dict.keys():
# 		astar.add_point(location_dict[loc],loc)
# 	# astar.add_point(1,Vector3(-1,0,-1))
# 	# astar.add_point(2,Vector3(0,0,-1))
# 	# astar.add_point(3,Vector3(1,0,-1))
# 	# astar.add_point(4,Vector3(-1,0,0))
# 	# astar.add_point(5,Vector3(0,0,0))
# 	# astar.add_point(6,Vector3(1,0,0))
# 	# astar.add_point(7,Vector3(-1,0,1))
# 	# astar.add_point(8,Vector3(0,0,1))
# 	# astar.add_point(9,Vector3(1,0,1))

# 	astar.connect_points(1,2)
# 	astar.connect_points(1,4)
# 	astar.connect_points(2,3)
# 	astar.connect_points(2,5)
# 	astar.connect_points(3,6)
# 	astar.connect_points(4,5)
# 	astar.connect_points(4,7)
# 	astar.connect_points(5,6)
# 	astar.connect_points(5,8)
# 	astar.connect_points(6,9)
# 	astar.connect_points(7,8)
# 	astar.connect_points(8,9)

# 	# astar.connect_points(2,1)
# 	# astar.connect_points(3,2)
# 	# astar.connect_points(4,1)
# 	# astar.connect_points(5,2)
# 	# astar.connect_points(5,4)
# 	# astar.connect_points(6,3)
# 	# astar.connect_points(6,5)
# 	# astar.connect_points(7,4)
# 	# astar.connect_points(8,5)
# 	# astar.connect_points(8,7)
# 	# astar.connect_points(9,6)
# 	# astar.connect_points(9,8)

# 	for conn in location_dict.values():
# 		connection_dict[conn] = astar.get_point_connections(conn)
# 	print(connection_dict)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Activate"):
		print(mesh_1.get_children())
		print(get_children())
		print(mesh_3.get_children())
	elif Input.is_action_just_pressed("Quick Select 1"):
		mesh_1.add_child(mesh_2)
	elif Input.is_action_just_pressed("Deactivate"):
		if mesh_2.get_parent() == mesh_1:
			mesh_1.remove_child(mesh_2)
		mesh_3.add_child(mesh_2)
	# if Input.is_action_just_pressed("Activate"):
	# 	for conn in connection_dict[5]:
	# 		astar.connect_points(conn,5,false)
	# elif Input.is_action_just_pressed("Quick Select 1"):
	# 	for conn in connection_dict[4]:
	# 		astar.disconnect_points(conn,4,false)
	# 	for conn in connection_dict[5]:
	# 		astar.disconnect_points(conn,5,false)
	# 	for conn in connection_dict[6]:
	# 		astar.disconnect_points(conn,6,false)
	# elif Input.is_action_just_pressed("Deactivate"):
	# 	var path = astar.get_point_path(1,9,false)
	# 	print(path)
	# 	var new_path = []
	# 	for point in path:
	# 		new_path.append(location_dict[point])
	# 	print(new_path)
