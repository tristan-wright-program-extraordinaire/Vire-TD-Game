extends SelectionScreen

# const TURRET_REWARD = preload("res://Resources/Reward/Turret_Reward.tres")
# const TURRET_REWARD_BUTTON = preload("res://Scenes/UI/Turret_Reward_Button.tscn")

# func open_for_level(_level: int) -> void:
# 	_clear_options()
# 	var screen_size = get_viewport_rect().size

# 	for i in range(options_count):
# 		var r = TURRET_REWARD.duplicate()

# 		var variance = randi_range(-1,1)
# 		r.rarity = clamp(_level + variance, 0, ENUMS.Rarity.size() - 1)

# 		r.glyph = randi_range(0, ENUMS.Glyph.size() - 1)

# 		var btn = TURRET_REWARD_BUTTON.instantiate()
# 		btn.call_deferred("_update_labels",r)
# 		btn.reward = r
# 		btn.custom_minimum_size = Vector2(
# 			screen_size.x / (options_count + 2),
# 			screen_size.y * 0.5
# 		)

# 		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER

# 		btn.connect("turret_button_pressed",_on_option_pressed)
# 		options_container.add_child(btn)
