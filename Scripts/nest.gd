extends "res://Scripts/structure.gd"

signal nest_destroyed

const ENEMY = preload("res://Scenes/Enemy.tscn")

@onready var screen_notifier: Node = %ScreenNotifier
@onready var nest_mesh: Node = %NestMesh

@export var health: float = 100.0
@export var nest_position: Vector3

var placing_structure : Placing_Structure

var occupying_node_id: int

var path_to_fountain: MeshInstance3D
var path_material: StandardMaterial3D
var anim_player: AnimationPlayer
var nav_path_fountain: Array

func _ready() -> void:
	nest_mesh.position = nest_position + Vector3(0,0.598681,0)
	
	path_to_fountain = MeshInstance3D.new()
	add_child(path_to_fountain)

	path_material = StandardMaterial3D.new()
	path_to_fountain.material_override = path_material

	anim_player = AnimationPlayer.new()
	add_child(anim_player)

	var anim_lib = AnimationLibrary.new()
	anim_player.add_animation_library("",anim_lib)

	var anim = Animation.new()
	anim.length = 2.0
	anim.loop_mode = 0

	var anim_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(anim_track,"%s:material_override:albedo_color" % path_to_fountain.get_path())
	anim.track_insert_key(anim_track, 0.0, Color.RED)
	anim.track_insert_key(anim_track, 2.0, Color.TRANSPARENT)

	anim_lib.add_animation("deny_placing",anim)

	placing_structure = ResourceLoader.load("res://Resources/Structure/Nest.tres")
	placing_sequence(nest_position)

func placing_sequence(location) -> void:
	var protection_tiles = get_parent().tile_grid.get_location_astar_connections(location,placing_structure.protection_radius,placing_structure.placing_group)
	for corruption in protection_tiles:
		var instance = instance_from_id(corruption.tile_id)
		instance.state_machine.set_state("corrupted")
	var prevention_tiles = get_parent().tile_grid.get_location_astar_connections(location,placing_structure.prevention_radius,placing_structure.placing_group)
	for prevention in prevention_tiles:
		var instance = instance_from_id(prevention.tile_id)
		instance.nest_spawn_prevented = true
	var restriction_nodes = get_nearest_nodes_in_group("Snap Point",location,placing_structure.restriction_radius)
	for restriction in restriction_nodes:
		# _add_debug_sphere(restriction.global_position,Color.BLUE)
		if restriction.has_method("add_restriction"):
			restriction.add_restriction(get_instance_id())

# func _input(_event):
# 	if Input.is_action_just_pressed("Quick Select 2"):
# 		_on_spawn_timeout()

func _on_round_start() -> void:
	print("Round started for: " + name)
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = false
	timer.connect("timeout",_on_spawn_timeout)
	timer.start()

func death() -> void:
	print(str(get_instance_id()) + " Nest Died")
	nest_destroyed.emit(get_instance_id())
	queue_free()

func create_nav_path(nav_path) -> void:
	var width = 0.15
	if nav_path.size() > 1:
		var curve = Curve3D.new()
		for point in nav_path:
			curve.add_point(point)
		curve.bake_interval = 0.1
		var baked_points = curve.get_baked_points()
		var path_mesh = ImmediateMesh.new()
		path_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, path_material)
		for index in range(baked_points.size() - 1):
			var from = baked_points[index]
			var to = baked_points[index+1]

			var direction = (to - from).normalized()
			var up = Vector3.UP

			var right = direction.cross(up).normalized()
			var left = -right

			var point_on_right = from + right * width
			path_mesh.surface_add_vertex(point_on_right)
			var point_on_left = from + left * width
			path_mesh.surface_add_vertex(point_on_left)
		path_mesh.surface_end()
		# if !path_to_fountain:
		# 	path_to_fountain = MeshInstance3D.new()
		# 	add_child(path_to_fountain)
		path_to_fountain.mesh = path_mesh
		nav_path_fountain = nav_path
	else:
		if path_to_fountain:
			path_to_fountain.mesh = null
			nav_path_fountain = nav_path

func check_nav_path():
	return true
	
func _on_spawn_timeout() -> void:
	print("Spawn Enemy")
	var enemy = ENEMY.instantiate()
	enemy.position = nest_position
	enemy.set_path(nav_path_fountain)
	get_parent().add_child(enemy)

func block_placement() -> void:
	anim_player.play("deny_placing")
