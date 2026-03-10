extends Area3D

@onready var collision: Node = %StructureAreaCollision

var radius: float
var placing_group: String
var permission_group: String

var permission_dict: Dictionary = {}
var restriction_arr: Array = []

var placeable: bool = false

func _ready() -> void:
	collision.shape.radius = radius

func force_radius_update() -> void:
	collision.shape.radius = radius

func get_permission_dict():
	permission_dict = {}
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group(permission_group):
			var this_placeable = area.get_parent().check_placeable()
			permission_dict[area.get_instance_id()] = this_placeable
	return permission_dict

func check_placement():
	var curr_permission: bool = true
	for permission in permission_dict:
		if !permission_dict[permission]:
			curr_permission = false
	# return curr_permission
	placeable = curr_permission
	get_parent().update_permission(curr_permission)

func update_permission():
	permission_dict = {}
	restriction_arr = []
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group(permission_group):
			var this_placeable = area.get_parent().check_placeable()
			permission_dict[area.get_instance_id()] = this_placeable
		elif area.is_in_group(placing_group):
			restriction_arr.append(area.get_instance_id())
	check_placement()
	# get_parent().update_permission(check_placement())
	

func _on_area_exited(area:Area3D) -> void:
	if area.is_in_group(permission_group):
		area.get_parent().return_to_normal()
		permission_dict.erase(area.get_instance_id())
		check_placement()
		# get_parent().update_permission(check_placement())
	elif area.is_in_group(placing_group):
		restriction_arr.erase(area.get_instance_id())
		check_placement()
		# get_parent().update_permission(check_placement())

func _on_area_entered(area:Area3D) -> void:
	if area.is_in_group(permission_group):
		var this_placeable = area.get_parent().check_placeable()
		permission_dict[area.get_instance_id()] = this_placeable
		check_placement()
		# get_parent().update_permission(check_placement())
	elif area.is_in_group(placing_group):
		restriction_arr.append(area.get_instance_id())
		check_placement()
		# get_parent().update_permission(check_placement())

func update_restrictions(structure) -> void:
	update_permission()
	structure.restrictions = restriction_arr
	var structure_id = structure.get_instance_id()
	for restriction in restriction_arr:
		instance_from_id(restriction).add_restriction(structure_id)
