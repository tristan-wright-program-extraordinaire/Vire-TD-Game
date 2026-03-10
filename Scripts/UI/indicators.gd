extends CanvasLayer

const INDICATOR_SCENE = preload("res://Scenes/off_screen_indicator.tscn")

# @onready var camera: Node = %Camera3D

func add_target(_target: VisibleOnScreenNotifier3D):
	var indicator = INDICATOR_SCENE.instantiate()
	indicator.target = _target
	add_child(indicator)

func remove_target(_target: VisibleOnScreenNotifier3D):
	for child in get_children():
		if child.target == _target:
			remove_child(child)
			break