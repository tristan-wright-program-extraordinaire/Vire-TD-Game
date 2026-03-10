extends CharacterBody3D

const SPEED = 50.0

@export var starting_health := 200.0

var path : Array
var current_point_index: int

var player = null
var health : float

func _ready() -> void:
	health = starting_health
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func take_damage(damage):
	health -= damage
	if health <= 0:
		death()

func death():
	queue_free()

func set_path(nav_path):
	path = nav_path
	current_point_index = 0

func _physics_process(delta: float) -> void:
	if path.is_empty():
		return

	if current_point_index >= path.size():
		return # Reached end of path

	var target_pos: Vector3 = path[current_point_index]
	var direction: Vector3 = (target_pos - global_position).normalized()
	
	velocity = direction * (SPEED * delta)
	move_and_slide()

	# Check if close to the current waypoint
	if global_position.distance_to(target_pos) < 0.2:
		current_point_index += 1
