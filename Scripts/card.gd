extends Node3D

@onready var area : Area3D = %Card_Area

@export var reward: Reward

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _use_card() -> void:
	queue_free()
