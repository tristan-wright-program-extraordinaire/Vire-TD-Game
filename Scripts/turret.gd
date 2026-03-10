extends "res://Scripts/structure.gd"

var placing_structure : Placing_Structure
var reward : Reward

# const ENUMS = preload("res://Scripts/Enums.gd")
const PLACEHOLDER_MATERIAL = preload("res://Shaders/Placeholder_Material.tres")
const BULLET = preload("res://Scenes/Bullet.tscn")
const TURRET_GUN = preload("res://Scenes/TurretGun.tscn")

@onready var targeting_area: Area3D = %TargetingArea
@onready var state_machine : Node = %Structure_State_Machine
@onready var base : Node3D = %Base
@onready var shooting_interval : Timer = %ShootingInterval

var is_placeholder := false
var has_target := false
var targets := []
var target : Node3D
var current_element : int
var kindle_amount : float = 0.0
var essence_cost: float = 0.0
var firing_range: float = 0.0
var projectile_damage: float = 0.0
var glyph: int = -1
var rarity: int = -1
var empowered_stats: Dictionary = {}

var gun: Node3D

var rarity_multiplier: Dictionary = {
	ENUMS.Rarity.COMMON: 1.0,
	ENUMS.Rarity.RARE: 1.1,
	ENUMS.Rarity.EPIC: 1.25,
	ENUMS.Rarity.LEGENDARY: 1.5
}

func _ready() -> void:
	placing_structure = ResourceLoader.load("res://Resources/Structure/Turret.tres")
	print("HERE")
	print(turret_gun_database.database)
	

func _process(_delta: float) -> void:
	if has_target and is_instance_valid(target):
		var thisVector = target.global_position
		gun.look_at(thisVector,Vector3(0,0.5,0),true)
		shoot()

func _update_material(_new_material: Material) -> void:
	if state_machine.state == "ready":
		pass
	else:
		var base_children = base.get_children()
		for child in base_children:
			child.material_override = _new_material
		# base.get_child(0).material_override = _new_material

func findTarget():
	target = targets[0]
	
func aim(_target):
	return true
	
func shoot():
	var bullet = BULLET.instantiate()
	bullet.transform = gun.transform
	add_child(bullet)
	has_target = false
	print(essence_cost)
	print(kindle_amount)
	print(essence_cost / kindle_amount)
	shooting_interval.wait_time = essence_cost / kindle_amount
	shooting_interval.start()
	_update_state("charging")

func _on_targeting_area_body_entered(body: Node3D) -> void:
	targets.append(body)
	if state_machine.state == "waiting_to_fire":
		target = body
		has_target = true

func _on_targeting_area_body_exited(body: Node3D) -> void:
	targets.erase(body)

func _on_shooting_interval_timeout() -> void:
	if len(targets) > 0:
		findTarget()
		has_target = true
	else:
		_update_state("waiting_to_fire")

func placing_sequence(location:Vector3) -> void:
	print("Placing: " + str(name))
	var protection_tiles = get_parent().tile_grid.get_location_astar_connections(location,placing_structure.protection_radius,placing_structure.placing_group)
	for protection in protection_tiles:
		var instance = instance_from_id(protection.tile_id)
		instance.add_protected(get_instance_id())
		protections.append(protection.tile_id)
	var prevention_tiles = get_parent().tile_grid.get_location_astar_connections(location,placing_structure.prevention_radius,placing_structure.placing_group)
	for prevention in prevention_tiles:
		var instance = instance_from_id(prevention.tile_id)
		instance.nest_spawn_prevented = true
	var restriction_nodes = get_nearest_nodes_in_group("Snap Point",location,placing_structure.restriction_radius)
	for restriction in restriction_nodes:
		# _add_debug_sphere(restriction.global_position,Color.YELLOW)
		if restriction.has_method("add_restriction"):
			restriction.add_restriction(get_instance_id())
	state_machine.call_deferred("set_state","ready")
	gun = TURRET_GUN.instantiate()
	gun.position = Vector3(0.0,0.891,0.0)
	add_child(gun)
	shooting_interval.start()
	var new_targeting_shape = CylinderShape3D.new()
	new_targeting_shape.radius = turret_gun_database.database[0][reward.glyph].base_range * rarity_multiplier[reward.rarity]
	targeting_area.get_node("TargetingCollision").shape = new_targeting_shape

	glyph = reward.glyph
	rarity = reward.rarity
	empowered_stats = reward.empowered_stats
	# targeting_shape.radius = turret_gun_database.database[0][reward.glyph].base_range * rarity_multiplier[reward.rarity]
	print("HERE")
	print(turret_gun_database.database[0][reward.glyph].base_range * rarity_multiplier[reward.rarity])
	# Place the Gun on the turret at Vector3(0.0,0.891,0.0)

func _update_state(_new_state: String):
	state_machine.set_state(_new_state)

func test_blocking(structure_area):
	var temp_dict : Dictionary = {}
	for permission in structure_area.permission_dict:
		var instance = instance_from_id(permission)
		if instance.is_in_group("Tile"):
			var tile = instance.get_parent()
			temp_dict[permission] = tile.movement_collision.affect_navigation_mesh
			tile.block_movement()
	return temp_dict

func _update_element(_new_element: int) -> void:
	current_element = _new_element

	var gun_data = turret_gun_database.database[_new_element][reward.glyph]
	essence_cost = gun_data.base_cost
	firing_range = gun_data.base_range
	projectile_damage = gun_data.base_damage

	_update_essence_cost(gun_data.base_cost)

func _update_essence_cost(_new_cost: float) -> void:
	essence_cost = _new_cost

func _update_kindle_amount(_new_amount: float) -> void:
	if kindle_amount == 0 and _new_amount > 0:
		shooting_interval.wait_time = essence_cost / _new_amount
		shooting_interval.start()
		_update_state("charging")
	elif _new_amount > 0:
		var completed_portion = (shooting_interval.wait_time - shooting_interval.time_left) / kindle_amount
		var left_to_do = essence_cost - completed_portion
		if left_to_do <= 0:
			shooting_interval.stop()
			_on_shooting_interval_timeout()
		else:
			shooting_interval.wait_time = left_to_do / _new_amount
			shooting_interval.start()
	elif _new_amount == 0:
		shooting_interval.stop()
	kindle_amount = _new_amount
