extends "res://Scripts/StateMachine.gd"

const STRUCTURE_AREA_SCENE = preload("res://Scenes/StructureArea.tscn")

func _ready():
	add_state("placing")
	add_state("picking_card")
	add_state("holding_card")
	add_state("watching")
	add_state("paused")
	call_deferred("set_state", "watching")
	
func _enter_state(new_state, _old_state):
	match new_state:
		"placing":
			print("Cursor Entering Placing")
			parent.scene_to_place = parent.placing_structure.scene.instantiate()
			parent.scene_to_place.is_placeholder = true
			parent.cursor.add_child(parent.scene_to_place)
			parent._set_scene_state("hovering")
		"picking_card":
			print("Cursor Entering Picking Card")
		"holding_card":
			print("Cursor Entering Holding Card")
		"watching":
			print("Cursor Entering Watching")
		"paused":
			print("Cursor Entering Paused")
	state = new_state

func _exit_state(old_state, _new_state):
	match old_state:
		"placing":
			print("Cursor Leaving Placing")
			# parent.structure_area.queue_free()
			parent.scene_to_place.queue_free()
			parent.placement_area = null
		"picking_card":
			print("Cursor Leaving Picking Card")
		"holding_card":
			print("Cursor Leaving Holding Card")
		"watching":
			print("Cursor Leaving Watching")
		"paused":
			print("Cursor Leaving Paused")
