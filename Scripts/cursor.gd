extends Node3D

signal placing_a_structure


@onready var camera = get_viewport().get_camera_3d() # Get the active 3D camera
@onready var state_machine: Node = %Player_State_Machine
@onready var this_area: Node = %CursorArea3D
@onready var cursor: Node = %Cursor
@onready var level_root: Node = get_parent()
@onready var hand: Node3D = %Hand

@export var placing_structure: Placing_Structure
var placement_area: Area3D
var card_area: Area3D
var scene_to_place: Node
var selected_card: Node3D
var possible_tiles: Array[Area3D] = []
var structure_area: Node
var attempting_to_place: Node

var start_tween: Tween
var end_tween: Tween


const ENUMS = preload("res://Scripts/Enums.gd")
const placeable_structure = preload("res://Shaders/Placeable_Structure.tres")
const not_placeable_structure = preload("res://Shaders/Not_Placeable_Structure.tres")
const hovering_structure = preload("res://Shaders/Placeholder_Material.tres")


func _process(_delta):
	if camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_normal = camera.project_ray_normal(mouse_pos)

		var ground_plane

		if ["picking_card"].has(state_machine.state):
			ground_plane = Plane(-hand.global_transform.basis.z.normalized(),hand.global_position)
			this_area.get_child(0).shape.radius = .1
		else:
			ground_plane = Plane(Vector3(0, 1, 0), 0) 
			this_area.get_child(0).shape.radius = .4

		var intersect_point = ground_plane.intersects_ray(ray_origin, ray_origin + ray_normal * 1000) # Ray length can be adjusted

		if intersect_point != null:
			cursor.global_transform.origin = intersect_point

func _ready():
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Activate"):
		if not Rect2(Vector2(),level_root.inspector_window.size).has_point(level_root.inspector_window.get_local_mouse_position()):
			level_root.inspector_window.visible = false
		match state_machine.state:
			"placing":
				if placement_area:
					var root_placeable = level_root.check_placeable(placement_area.global_position,placing_structure)
					if placement_area.placeable and root_placeable:
						var placedStructure = placing_structure.scene.instantiate()
						level_root.add_child(placedStructure)
						placedStructure.global_position = placement_area.global_position
						placedStructure.global_rotation = scene_to_place.global_rotation
						placedStructure.reward = selected_card.reward
						placedStructure.placing_sequence(placement_area.global_position)
						placement_area = null
						hand.cards.erase(selected_card)
						if hand.cards.size() > 0:
							hand._arrange_cards(floor(hand.cards.size() / 2.0),false)
						selected_card._use_card()
						selected_card = null
						if level_root.current_hud.has_method("_hand_hover"):
							if !level_root.current_hud._hand_hover():
								state_machine.set_state("watching")
						else:		
							state_machine.set_state("watching")
			"watching":
				var areas = this_area.get_overlapping_areas()
				for area in areas:
					if area.is_in_group("Turret") and selected_card == null and area.get_parent().reward:
						if not level_root.inspector_window.visible:
							level_root.inspector_window.visible = true
						var this_turret = area.get_parent()
						print(this_turret.reward.empowered_stats)
						level_root.inspector_window.set_values(this_turret)
						var screen_size = level_root.inspector_window.get_viewport_rect().size
						level_root.inspector_window.custom_minimum_size = Vector2(
							screen_size.x * 0.2,
							screen_size.y * 0.8
						)
						for slider in level_root.inspector_window.sliders:
							slider.custom_minimum_size = Vector2(
								level_root.inspector_window.custom_minimum_size.x * 0.8,
								level_root.inspector_window.custom_minimum_size.y * 0.1
							)
						level_root.inspector_window.kindle_slider.custom_minimum_size = Vector2(
							level_root.inspector_window.custom_minimum_size.x * 0.8,
							level_root.inspector_window.custom_minimum_size.y * 0.1
						)
						# level_root.inspector_window.slider.custom_minimum_size.x = level_root.inspector_window.custom_minimum_size.x * 0.8
						break
			"holding_card":
				if selected_card.get_parent() == cursor:
					if end_tween:
						end_tween.finished.disconnect(_end_placing)
						end_tween.stop()
					if start_tween:
						start_tween.finished.disconnect(_start_placing)
						start_tween.stop()
					selected_card.reparent(hand,true)
					hand._arrange_cards(hand.cards.find(selected_card),false)
					state_machine.set_state("watching")
	elif Input.is_action_just_pressed("Activate"):
		match state_machine.state:
			"picking_card":
				state_machine.set_state("holding_card")

				start_tween = create_tween()
				start_tween.tween_property(selected_card,"position",selected_card.position + Vector3(0.0,1.0,0.0),0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
				start_tween.finished.connect(_start_placing)

	elif Input.is_action_just_pressed("Quick Select 1"):
		state_machine.set_state("placing")
	elif Input.is_action_just_pressed("Quick Select 2"):
		hand._add_card(placing_structure)
	elif Input.is_action_just_pressed("Deactivate"):
		print(cursor.get_children())
		print(selected_card)

func _start_placing() -> void:
	selected_card.reparent(cursor,true)
	placing_structure = selected_card.reward.placing_structure
	print(placing_structure)
	print(selected_card.rotation)
	end_tween = create_tween()
	end_tween.parallel().tween_property(selected_card,"position",Vector3(0.0,5.0,0.0),0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var rot_y = roundi(selected_card.rotation_degrees.y / 180.0) * 180
	end_tween.parallel().tween_property(selected_card,"rotation_degrees",Vector3(90.0,rot_y,0.0),0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	end_tween.finished.connect(_end_placing)

func _end_placing() -> void:
	if selected_card.get_parent() == cursor:
		state_machine.set_state("placing")
	print(selected_card.rotation)

func update_permission(placeable) -> void:
	if placeable:
		(scene_to_place.find_child("Base",true,false) as MeshInstance3D).set_surface_override_material(0, placeable_structure)
	else:
		(scene_to_place.find_child("Base",true,false) as MeshInstance3D).set_surface_override_material(0, not_placeable_structure)


func _on_area_3d_area_entered(area:Area3D) -> void:
	if state_machine.state == "placing":
		if area.is_in_group(placing_structure.placing_group) and placement_area == null:
			_temporary_placement(area)
	elif state_machine.state == "picking_card":
		if area.is_in_group("Card") and card_area == null:
			_select_card(area)


func _on_area_3d_area_exited(area: Area3D) -> void:
	if state_machine.state == "placing":
		if area.is_in_group(placing_structure.placing_group):
			if area == placement_area and scene_to_place.get_parent() == level_root:
				level_root.remove_child(scene_to_place)
				for tile in possible_tiles:
					tile.get_parent().return_to_normal()
				var areas = this_area.get_overlapping_areas()
				placement_area = null
				for x in areas:
					if x.is_in_group(placing_structure.placing_group):
						_temporary_placement(x)
				if not placement_area:
					cursor.add_child(scene_to_place)
					scene_to_place.global_position = cursor.global_position
					_set_scene_state("hovering")
	elif state_machine.state == "picking_card":
		if area.is_in_group("Card"):
			if area == card_area:
				var areas = this_area.get_overlapping_areas()
				card_area = null
				for x in areas:
					if x.is_in_group("Card"):
						_select_card(x)
						break
				# if not card_area:
				# 	print("Deselected Card")
				# 	hand._arrange_cards(hand.cards.find(selected_card),false)


func _temporary_placement(area: Area3D) -> void:
	placement_area = area
	if scene_to_place.get_parent() == cursor:
		cursor.remove_child(scene_to_place)
	level_root.add_child(scene_to_place)
	
	var tile_angle: bool = level_root.tile_grid.get_tile_angle(placement_area.global_position)
	if tile_angle:
		scene_to_place.global_rotation.y = deg_to_rad(30.0)
	else:
		scene_to_place.global_rotation.y = deg_to_rad(-30.0)

	scene_to_place.global_position = area.global_position
	if area.placeable:
		_set_scene_state("allowed")
	else:
		_set_scene_state("blocked")

func _set_scene_state(new_state:String) -> void:
	if scene_to_place.has_method("_update_state"):
		scene_to_place._update_state(new_state)

func _select_card(area: Area3D) -> void:
	card_area = area
	selected_card = area.get_parent()
	hand._arrange_cards(hand.cards.find(selected_card),true)
	print("Selected Card")
	print(selected_card.position)
