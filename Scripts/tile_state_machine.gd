extends "res://Scripts/StateMachine.gd"

var tile_materials: Dictionary

func _ready():
	add_state("grass")
	add_state("corrupted")
	add_state("nest")
	add_state("portal")
	add_state("cement")
	call_deferred("set_state", "grass")

	
func _enter_state(_new_state, _old_state):
	match _new_state:
		"grass":
			parent.mesh_instance_3d.set_surface_override_material(0, tile_materials.grass)
			pass
		"corrupted":
			parent.mesh_instance_3d.set_surface_override_material(0, tile_materials.corrupted)
			pass
		"nest":
			parent.mesh_instance_3d.set_surface_override_material(0, tile_materials.nest)
			pass
		"portal":
			if _old_state == "corrupted":
				parent.mesh_instance_3d.set_surface_override_material(0, tile_materials.corrupted_portal)
			else:
				parent.mesh_instance_3d.set_surface_override_material(0, tile_materials.portal)
			pass
		"cement":
			parent.mesh_instance_3d.set_surface_override_material(0, tile_materials.cement)
			parent.block_movement()


func _exit_state(_old_state, _new_state):
	match _new_state:
		"grass":
			pass
		"corrupted":
			pass
		"nest":
			pass
		"portal":
			pass
		"cement":
			parent.allow_movement()
