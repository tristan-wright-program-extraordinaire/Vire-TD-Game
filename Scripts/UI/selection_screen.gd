class_name SelectionScreen
extends Control

signal reward_selected(reward: Reward)
signal selections_satisfied()

const ENUMS = preload("res://Scripts/Enums.gd")
const TURRET_REWARD = preload("res://Resources/Reward/Turret_Reward.tres")
const TURRET_REWARD_BUTTON = preload("res://Scenes/UI/Turret_Reward_Button.tscn")
const KINDLE_REWARD = preload("res://Resources/Reward/Kindle_Reward.tres")
const KINDLE_REWARD_BUTTON = preload("res://Scenes/UI/Kindle_Reward_Button.tscn")
const TOKEN_REWARD = preload("res://Resources/Reward/Token_Reward.tres")
const TOKEN_REWARD_BUTTON = preload("res://Scenes/UI/Token_Reward_Button.tscn")

@export var options_count: int = 5
@export var selections_count: int = 2

@onready var options_container: Control = %OptionsContainer
@onready var scaling: Node = %Scaling

func open_for_level(_level: float,_reward_type: int) -> void:
	_clear_options()
	var screen_size = get_viewport_rect().size
	var this_reward = TURRET_REWARD
	var this_button = TURRET_REWARD_BUTTON

	match _reward_type:
		ENUMS.Rewards.TURRET:
			this_reward = TURRET_REWARD
			this_button = TURRET_REWARD_BUTTON
		ENUMS.Rewards.KINDLE:
			this_reward = KINDLE_REWARD
			this_button = KINDLE_REWARD_BUTTON
		ENUMS.Rewards.TOKEN:
			this_reward = TOKEN_REWARD
			this_button = TOKEN_REWARD_BUTTON

	print("LEVEL")
	print(_level)

	for i in range(options_count):
		var r = this_reward.duplicate()

		match _reward_type:
			ENUMS.Rewards.TURRET:
				r.rarity = scaling.roll_value(_level)
				r.glyph = randi_range(0, ENUMS.Glyph.size() - 1)
				var possible_stats: Array[ENUMS.Stats] = []
				for stat in range(ENUMS.Stats.size()):
					possible_stats.append(stat)
				possible_stats.shuffle()
				var stats_to_empower = possible_stats.slice(0,r.rarity+1)
				var temp_stat_dict = {}
				for stat in stats_to_empower:
					temp_stat_dict[stat] = 0.0
				r.empowered_stats = temp_stat_dict
			ENUMS.Rewards.KINDLE:
				r.rarity = scaling.roll_value(_level)
				r.element = randi_range(0, ENUMS.Element.size() - 1)
				r.amount = 1.0
			ENUMS.Rewards.TOKEN:
				r.rarity = scaling.roll_value(_level)
				r.empowered_stat = randi_range(0, ENUMS.Stats.size() - 1)


		var btn = this_button.instantiate()
		btn.call_deferred("_update_labels",r)
		btn.reward = r
		btn.custom_minimum_size = Vector2(
			screen_size.x / (options_count + 2),
			screen_size.y * 0.5
		)

		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		btn.connect("reward_button_pressed",_on_option_pressed)
		options_container.add_child(btn)

func _on_option_pressed(reward: Reward,selection: Button) -> void:
	reward_selected.emit(reward)
	print(reward)
	if options_container.get_children().size() > options_count - (selections_count - 1):
		selection.queue_free()
	else:
		selections_satisfied.emit()
		hide()
		queue_free()

func _clear_options() -> void:
	for child in options_container.get_children():
		child.queue_free()
