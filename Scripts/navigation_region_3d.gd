extends NavigationRegion3D

signal bake_actually_finished

const MAX_CHECKS := 50

func _on_bake_finished() -> void:
	# call_deferred("_ensure_region_ready",0)
	_check_navigation_ready()

func _check_navigation_ready():
	# print(get_navigation_layer_value(1))
	# print(navigation_mesh)
	# print(NavigationServer3D.region_get_map(get_rid()))
	# await get_tree().create_timer(1.0).timeout
	# # var nav_map = get_world_3d().navigation_map
	# if not NavigationServer3D.region_get_map(get_rid()) == RID():
	# 	call_deferred("_check_navigation_ready")
	# else:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	bake_actually_finished.emit()
	print("here")


# func _ensure_region_ready(attempt: int) -> void:
# 	# attempt limit
# 	if attempt >= MAX_CHECKS:
# 		push_warning("NavigationRegion: readiness check reached MAX_CHECKS; emitting navigation_ready anyway.")
# 		emit_signal("navigation_ready")
# 		return

# 	var aabb = get_bounds()
# 	var center = aabb.position + aabb.size * 0.5
# 	var nearby = center + Vector3(0.1, 0.0, 0.1)  # very small offset

# 	var path = NavigationServer3D.map_get_path(map, center, nearby, true)
# 	if path.size() >= 2:
# 		bake_actually_finished.emit()
# 		return

# 	# If empty, it might mean navmesh not fully usable yet — try again next deferred call.
# 	call_deferred("_ensure_region_ready", attempt + 1)
