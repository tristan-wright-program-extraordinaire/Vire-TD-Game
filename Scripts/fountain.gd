extends "res://Scripts/structure.gd"

signal fountain_is_ready

const ENUMS = preload("res://Scripts/Enums.gd")

var placing_structure: Placing_Structure
var kindle_reserves: Dictionary

func _ready() -> void:
	placing_structure = ResourceLoader.load("res://Resources/Structure/Fountain.tres")
	print(placing_structure)
	for element in range(ENUMS.Element.size()):
		kindle_reserves[element] = {
			"total": 0.0,
			"used": 0.0,
			"viren": []
		}

func _input(_event):
	if Input.is_action_just_pressed("Quick Select 2"):
		print(kindle_reserves)

func placing_sequence(_location:Vector3) -> void:
	print(is_node_ready())
	print(placing_structure)
	var portal_tiles = get_parent().tile_grid.get_location_astar_connections(Vector3.ZERO,placing_structure.protection_radius,placing_structure.placing_group)
	for portal in portal_tiles:
		var instance = instance_from_id(portal.tile_id)
		instance.state_machine.set_state("portal")
		
	var prevention_tiles = get_parent().tile_grid.get_location_astar_connections(Vector3.ZERO,placing_structure.prevention_radius,placing_structure.placing_group)
	for prevention in prevention_tiles:
		var instance = instance_from_id(prevention.tile_id)
		instance.nest_spawn_prevented = true

	var restriction_nodes = get_nearest_nodes_in_group("Snap Point",Vector3.ZERO,placing_structure.restriction_radius)
	
	for restriction in restriction_nodes:
		# _add_debug_sphere(restriction.global_position,Color.RED)
		if restriction.has_method("add_restriction"):
			restriction.add_restriction(get_instance_id())

	fountain_is_ready.emit()