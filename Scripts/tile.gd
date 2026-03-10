extends StaticBody3D

@onready var mesh_instance_3d: MeshInstance3D = %HexagonMesh
@onready var state_machine: Node = $StateMachine
@onready var left_snap: Node = $"Left Snap Point"
@onready var right_snap: Node = $"Right Snap Point"

var nest_spawn_prevented: bool = false
var astar_id : int
var lookup : Vector2i
var astar_connections : Array[int] = []

const TILE_MATERIALS = {
	"grass": preload("res://Shaders/Tile_Grass_Material.tres"),
	"corrupted": preload("res://Shaders/Tile_Corrupted_Material.tres"),
	"nest": preload("res://Shaders/Tile_Nest_Material.tres"),
	"portal": preload("res://Shaders/Tile_Portal_Material.tres"),
	"corrupted_portal": preload("res://Shaders/Tile_Corrupted_Portal_Material.tres"),
	"cement": preload("res://Shaders/Tile_Cement_Material.tres"),
	"placeholder": preload("res://Shaders/Placeholder_Material.tres")
}

@export var protected : bool = false
var structure_arr: Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine.tile_materials = TILE_MATERIALS
	pass

# func _input(_event):
# 	if Input.is_action_just_pressed("Quick Select 2"):
# 		print(left_snap.global_position)
# 		print(right_snap.global_position)

func block_movement():
	var parent = get_parent()
	for conn in astar_connections:
		parent.astar.disconnect_points(conn,astar_id,false)
	
func allow_movement():
	var parent = get_parent()
	for conn in astar_connections:
		parent.astar.connect_points(conn,astar_id,false)

func add_protected(structure_id: int):
	structure_arr.append(structure_id)
	protected = true
	state_machine.set_state("cement")

func remove_protected(structure_id: int):
	structure_arr.erase(structure_id)
	protected = len(structure_arr) < 1

func check_placeable():
	if state_machine.state == "corrupted":
		mesh_instance_3d.set_surface_override_material(0, TILE_MATERIALS.placeholder)
		return false
	else:
		return true

func return_to_normal():
	if state_machine.state == "corrupted":
		mesh_instance_3d.set_surface_override_material(0, TILE_MATERIALS.corrupted)
