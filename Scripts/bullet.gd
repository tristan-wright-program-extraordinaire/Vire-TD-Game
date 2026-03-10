extends Area3D

@export var damage := 20

var speed := 15
var velocity : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = transform.basis.z * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	transform.origin += velocity * delta


func _on_body_entered(body: Node3D) -> void:
	body.take_damage(damage)
	queue_free()
