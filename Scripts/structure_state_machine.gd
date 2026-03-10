extends "res://Scripts/StateMachine.gd"

const placeable_structure = preload("res://Shaders/Placeable_Structure.tres")
const not_placeable_structure = preload("res://Shaders/Not_Placeable_Structure.tres")
const hovering_structure = preload("res://Shaders/Hovering_Structure.tres")
const ready_structure = preload("res://Shaders/Ready_Structure.tres")

func _ready():
	add_state("hovering")
	add_state("blocked")
	add_state("allowed")
	add_state("ready")
	add_state("charging")

func _enter_state(new_state, _old_state):
	match new_state:
		"hovering":
			parent._update_material(hovering_structure)
			# parent.base.set_surface_override_material(0, hovering_structure)
			print("Structure Entering Hovering")
		"blocked":
			parent._update_material(not_placeable_structure)
			# parent.base.set_surface_override_material(0, not_placeable_structure)
			print("Structure Entering Blocked")
		"allowed":
			parent._update_material(placeable_structure)
			# parent.base.set_surface_override_material(0, placeable_structure)
			print("Structure Entering Allowed")
		"ready":
			parent._update_material(ready_structure)
			# parent.base.set_surface_override_material(0, ready_structure)
			print("Structure Entering Ready")
		"charging":
			# parent._update_material(ready_structure)
			# parent.base.set_surface_override_material(0, ready_structure)
			print("Structure Entering Charging")
		"waiting_to_fire":
			# parent._update_material(ready_structure)
			# parent.base.set_surface_override_material(0, ready_structure)
			print("Structure Entering Waiting To Fire")
	state = new_state

func _exit_state(old_state, _new_state):
	match old_state:
		"hovering":
			print("Structure Leaving Hovering")
		"blocked":
			print("Structure Leaving Blocked")
		"allowed":
			print("Structure Leaving Allowed")
		"ready":
			print("Structure Leaving Ready")
		"charging":
			print("Structure Leaving Charging")
		"waiting_to_fire":
			print("Structure Leaving Waiting To Fire")
