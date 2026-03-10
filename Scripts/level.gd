extends Node3D

signal round_start
signal round_end

const NEST = preload("res://Scenes/Nest.tscn")
const ENEMY = preload("res://Scenes/Enemy.tscn")
const REWARDS = preload("res://Scenes/UI/Rewards.tscn")

@onready var hud: CanvasLayer = $HUD
@onready var level_state_machine: Node = %Level_State_Machine
@onready var cursor: Node = %Cursor
@onready var fountain: Node = %Fountain
@onready var tile_grid: Node = %TileGrid
@onready var _camera_position: Node = %Camera_Position
@onready var _camera: Node = %Camera3D
@onready var _indicators: Node = %Indicators
@onready var _turret_selection: Node = %TurretSelection
@onready var inspector_window: Control = %InspectorWindow
@onready var kindling: CanvasLayer = %FountainKindling

@export_group("Movement")
@export var move_speed := 25.0
@export var acceleration := 20.0
@export_range(0.0,5.0,0.5) var camera_bounciness := 2
@export var scroll_speed := 1.0
@export var scroll_max_speed := 20.0
@export var scroll_acceleration := 15.0
@export_range(0.0,5.0,0.5) var scroll_bounciness := 1

var velocity = Vector3.ZERO
var scroll_velocity = Vector3.ZERO

var	min_bound: Vector3
var	max_bound: Vector3

var scroll_min: float = 5.0
var scroll_max: float = 20.0

var currentStateMachine
var placedNexusLocation : Vector3
var placedNestLocation : Vector3

var current_wave: int = 0
var nest_dict: Dictionary = {}

var path_material = StandardMaterial3D.new()
var placing_structure : Node

var current_hud: CanvasLayer
var reward_screen: CanvasLayer

func start_round():
	current_wave += 1
	for nest in nest_dict:
		nest_dict[nest] =  {"round_end": false,"blocking":false,"blocking_test":false}
	round_start.emit()
	level_state_machine.set_state("wave")

func end_round():
	round_end.emit()
	level_state_machine.set_state("planning")
	pass

func _ready() -> void:
	print("Level Ready")
	path_material.albedo_color = Color.hex(0x00b8ffff) # Blue path color
	path_material.unshaded = true # Ensure color is not affected by lights
	_turret_selection.open_for_level(0.0,ENUMS.Rewards.TURRET)
	get_tree().paused = true
	
func _input(_event):
	if Input.is_action_just_pressed("Quick Select 3"):
		# _create_new_nest()
		reward_screen = REWARDS.instantiate()
		reward_screen.connect("reward_chosen",_on_reward_chosen)
		add_child(reward_screen)
		get_tree().paused = true
	elif Input.is_action_just_pressed("Quick Select 4"):
		start_round()
		# _update_nest_paths()
		# print("Wave " + str(current_wave) + " Start")
	elif Input.is_action_just_pressed("Scroll Up"):
		zoom(-1)
	elif Input.is_action_just_pressed("Scroll Down"):
		zoom(1)


func _physics_process(delta: float) -> void:
	var raw_input := Input.get_vector("Move Camera Left","Move Camera Right","Move Camera Forward","Move Camera Back")

	var move_direction := Vector3(0,0,1) * raw_input.y + Vector3(1,0,0) * raw_input.x
	move_direction = move_direction.normalized()

	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	_camera_position.global_position.x = clamp(_camera_position.global_position.x + velocity.x * delta,min_bound.x,max_bound.x)
	_camera_position.global_position.z = clamp(_camera_position.global_position.z + velocity.z * delta,min_bound.z,max_bound.z)

	if _camera_position.global_position.x in [min_bound.x,max_bound.x]:
		velocity = Vector3(velocity.x * (-0.2 * camera_bounciness),0,velocity.z)
	elif _camera_position.global_position.z in [min_bound.z,max_bound.z]:
		velocity = Vector3(velocity.x,0,velocity.z * (-0.2 * camera_bounciness))

	scroll_velocity = scroll_velocity.move_toward(Vector3.ZERO, scroll_acceleration * delta)
	_camera.position.z = clamp(_camera.position.z + scroll_velocity.z * delta, scroll_min,scroll_max)

	if _camera.position.z in [scroll_min,scroll_max]:
		scroll_velocity = Vector3(0,0,scroll_velocity.z * (-0.2 * scroll_bounciness))

func zoom(scroll_input):
	scroll_velocity = clamp(scroll_velocity + Vector3(0,0,(scroll_input * scroll_speed)),Vector3(0,0,-scroll_max_speed),Vector3(0,0,scroll_max_speed))


func _on_reward_chosen(reward):
	match reward.reward_type:
		ENUMS.Rewards.TURRET:
			cursor.hand._add_card(reward)
			print(ENUMS.Glyph.find_key(reward.glyph))
			print(ENUMS.Rarity.find_key(reward.rarity))
			print("turret")
		ENUMS.Rewards.TOKEN:
			print("token")
		ENUMS.Rewards.KINDLE:
			fountain.kindle_reserves[reward.element].total += reward.amount
			kindling.add_total(reward.element,reward.amount)
			print("kindle")
	# reward_screen.queue_free()
	# get_tree().paused = false


func _on_hud_placing(_placing_type: ENUMS.Placing) -> void:
	pass
	
func _on_hud_start_round() -> void:
	print("Starting Round")
	start_round()
	
func _on_spawn_timeout() -> void:
	var enemy = ENEMY.instantiate()
	enemy.nexus_location = placedNexusLocation
	enemy.position = placedNestLocation + Vector3(0,1,0)
	add_child(enemy)

func develop_corruption() -> void:
	pass


func _on_tile_grid_added_tiles(_min_bound,_max_bound) -> void:
	min_bound = _min_bound
	max_bound = _max_bound

	call_deferred("_startup")

	# fountain.call_deferred("placing_sequence",Vector3.ZERO)
	# fountain.placing_sequence(Vector3.ZERO)

	# # this_fountain = FOUNTAIN.instantiate()
	# this_fountain.position = Vector3.ZERO
	# print(this_fountain.position)
	# print(this_fountain)
	# add_child(this_fountain)

func _startup() -> void:
	fountain.placing_sequence(Vector3.ZERO)

func _on_fountain_fountain_is_ready() -> void:
	_create_new_nest()

func _create_new_nest():
	var nest_location = tile_grid.find_nest_location()
	var this_nest = NEST.instantiate()

	this_nest.occupying_node_id = nest_location.get_instance_id()
	this_nest.nest_position = nest_location.global_position
	_indicators.add_target(this_nest.find_child("ScreenNotifier",true,false))

	connect("round_start", Callable(this_nest, "_on_round_start"))
	this_nest.connect("nest_destroyed",_on_nest_destroyed)
	this_nest.connect("nest_round_end",_on_nest_round_end)
	# this_nest.connect("cant_reach_fountain",_on_nest_cant_reach_fountain)

	add_child(this_nest)
	nest_dict[str(this_nest.get_instance_id())] = {"round_end": true,"blocking":false,"blocking_test":false}
	_update_nest_paths()

func _on_nest_destroyed(nest_id) -> void:
	print(str(nest_id) + " was destroyed!")
	nest_dict.erase(str(nest_id))

func _on_nest_round_end(nest_id) -> void:
	nest_dict[str(nest_id)].round_end = true
	if nest_dict.values().all(func(x): return x.round_end):
		end_round()

func _update_nest_paths() -> bool:
	tile_grid.update_all_astar_weights()
	var allowed = true
	for nest in nest_dict:
		var this_nest = instance_from_id(int(nest))
		var from = this_nest.nest_position * Vector3(1,0,1)
		var to = Vector3.ZERO
		var path = tile_grid.find_nav_path(from,to)
		if path.size() > 0:
			this_nest.create_nav_path(path)
		else:
			this_nest.block_placement()
			allowed = false
	return allowed

func check_placeable(placement_location,this_placing_structure) -> bool:
	var permission_tiles = tile_grid.get_location_astar_connections(placement_location,1,this_placing_structure.placing_group)
	for permission in permission_tiles:
		var instance = instance_from_id(permission.tile_id)
		instance.block_movement()
		# var instance = instance_from_id(permission.tile_id)
		# if instance.is_in_group("Tile"):
		# 	var tile = instance.get_parent()
		# 	tile.block_movement()
	var legal_move = _update_nest_paths()
	for permission in permission_tiles:
		var instance = instance_from_id(permission.tile_id)
		if not instance.protected:
			instance.allow_movement()
		# if instance.is_in_group("Tile"):
		# 	var tile = instance.get_parent()
		# 	if not tile.protected:
		# 		tile.allow_movement()
	return legal_move

# func check_placeable(structure_area) -> bool:
# 	for permission in structure_area.permission_dict:
# 		var instance = instance_from_id(permission)
# 		if instance.is_in_group("Tile"):
# 			var tile = instance.get_parent()
# 			tile.block_movement()
# 	var legal_move = _update_nest_paths()
# 	for permission in structure_area.permission_dict:
# 		var instance = instance_from_id(permission)
# 		if instance.is_in_group("Tile"):
# 			var tile = instance.get_parent()
# 			if not tile.protected:
# 				tile.allow_movement()
# 	return legal_move

# func _on_cursor_placing_a_structure(structure_to_place) -> void:
# 	placing_structure = structure_to_place
# 	_update_nest_paths()



func _on_turret_selection_reward_selected(reward:Reward) -> void:
	_on_reward_chosen(reward)

func _on_turret_selection_selections_satisfied() -> void:
	get_tree().paused = false
