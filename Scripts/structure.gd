class_name Structure
extends Node3D

var restrictions : Array = []
var protections : Array = []

func placing_sequence(location:Vector3) -> void:
	pass

func update_permission(_placeable: bool) -> void:
	pass

func test_blocking(_permission_dict: Dictionary):
	return false

func end_test_blocking(_permission_dict: Dictionary):
	return false

func get_nearest_nodes_in_group(group, this_position, count):
	var nodes = get_parent().get_tree().get_nodes_in_group(group)
	# nodes.sort_custom( func(a,b): return a.global_position.distance_to(this_position)<b.global_position.distance_to(this_position) )
	# return nodes.slice(0,count)
	return nodes.filter( func(n): return n.global_position.distance_to(this_position) < count)

func _update_state(_new_state: String):
	pass

func _update_material(_new_material: Material) -> void:
	pass

func _add_debug_sphere(target_location: Vector3,color: Color) -> void:
	var new_mesh = MeshInstance3D.new()
	new_mesh.global_position = target_location
	new_mesh.mesh = SphereMesh.new()
	var new_material = StandardMaterial3D.new()
	new_mesh.material_override = new_material
	new_material.albedo_color = color
	get_parent().add_child(new_mesh)