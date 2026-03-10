extends Control

const ENUMS = preload("res://Scripts/Enums.gd")

@onready var glyph_label: Label = %GlyphLabel
@onready var rarity_label: Label = %RarityLabel
@onready var sliders: Array[Control] = [%FireRateSlider,%DamageTypeSlider,%ImpactSlider,%TargetingSlider]
@onready var elementDD: OptionButton = %ElementSelector
@onready var kindle_slider: Slider = %VirenPower

var active_turret

# # Called when the node enters the scene tree for the first time.
# func _ready() -> void:
# 	var screen_size = get_viewport_rect().size
# 	custom_minimum_size = Vector2(
# 		screen_size.x * 0.2,
# 		screen_size.y * 0.8
# 	)
# 	for slider in sliders:
# 		slider.custom_minimum_size = Vector2(
# 			custom_minimum_size.x * 0.8,
# 			custom_minimum_size.y * 0.1
# 		)
# 	kindle_slider.custom_minimum_size = Vector2(
# 		custom_minimum_size.x * 0.8,
# 		custom_minimum_size.y * 0.1
# 	)

func set_values(turret) -> void:
	active_turret = turret
	var current_element = turret.current_element
	var kindle_amount = turret.kindle_amount
	var available_kindle = 0
	if current_element > -1:
		var reserves = get_parent().fountain.kindle_reserves[current_element]
		available_kindle = reserves.total - reserves.used
	glyph_label.text = ENUMS.Glyph.find_key(turret.glyph)
	rarity_label.text = ENUMS.Rarity.find_key(turret.rarity)
	# var array_text = []
	print(turret.empowered_stats)
	for slider in sliders:
		if slider.stat in turret.empowered_stats:
			slider.slider.editable = true
			slider.slider.value = turret.empowered_stats[slider.stat]
			slider.stat_value.text = str(turret.empowered_stats[slider.stat])
		else:
			slider.slider.editable = false
			slider.slider.value = 0.0
			slider.stat_value.text = "0.0"
	elementDD.selected = current_element
	if current_element > -1:
		kindle_slider.editable = true
		kindle_slider.max_value = kindle_amount + available_kindle
		kindle_slider.value = kindle_amount
		kindle_slider.tick_count = ((kindle_amount + available_kindle) / 0.25) + 1
	# for stat in reward.empowered_stats:
	# 	array_text.append(ENUMS.Stats.find_key(stat))
	# 	slider.slider.value = reward.empowered_stats[stat]
	# 	slider.slider.editable = true


# func _on_h_slider_value_changed(value: float) -> void:
# 	for stat in _reward.empowered_stats:
# 		_reward.empowered_stats[stat] = value


func _on_slider_value_changed(stat: Variant, value: Variant) -> void:
	if stat in active_turret.empowered_stats:
		active_turret.empowered_stats[stat] = value
		# sliders[stat].


func _on_element_selector_item_selected(index:int) -> void:
	if not index == active_turret.current_element:
		var reserves = get_parent().fountain.kindle_reserves
		if active_turret.current_element > -1:
			reserves[active_turret.current_element].used -= active_turret.kindle_amount
			get_parent().kindling.add_amount(active_turret.current_element,active_turret.kindle_amount)
			active_turret._update_kindle_amount(0.0)
		kindle_slider.editable = true
		active_turret._update_element(index)
		print(reserves)
		print("Reserves total")
		print(reserves[index].total - reserves[index].used)
		kindle_slider.tick_count = ((reserves[index].total - reserves[index].used) / 0.25) + 1
		kindle_slider.max_value = reserves[index].total - reserves[index].used


func _on_viren_power_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var amount_changed = kindle_slider.value - active_turret.kindle_amount
		active_turret.kindle_amount += amount_changed
		get_parent().fountain.kindle_reserves[active_turret.current_element].used += amount_changed
		get_parent().kindling.add_amount(active_turret.current_element,(amount_changed * -1))
		print(kindle_slider.value)
