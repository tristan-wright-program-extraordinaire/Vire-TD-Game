extends CanvasLayer

signal reward_chosen(reward: Reward)

const ENUMS = preload("res://Scripts/Enums.gd")

# const TURRET_REWARD = preload("res://Resources/Reward/Turret_Reward.tres")
const TOKEN_REWARD = preload("res://Resources/Reward/Token_Reward.tres")
const KINDLE_REWARD = preload("res://Resources/Reward/Kindle_Reward.tres")

const REWARD_SELECT_SCENE = preload("res://Scenes/UI/Reward_Selection.tscn")

@onready var turret_button: BaseButton = %Turret_Button
@onready var token_button: BaseButton = %Token_Button
@onready var kindle_button: BaseButton = %Kindle_Button

@export var turret_choice_level: float = 0.0

func _on_turret_button_button_up() -> void:
	if turret_button.is_hovered():
		_create_selection_screen(ENUMS.Rewards.TURRET)


func _on_kindle_button_button_up() -> void:
	if kindle_button.is_hovered():
		print(ENUMS.Rewards.KINDLE)
		_create_selection_screen(ENUMS.Rewards.KINDLE)


func _on_token_button_button_up() -> void:
	if token_button.is_hovered():
		print(ENUMS.Rewards.TOKEN)
		_create_selection_screen(ENUMS.Rewards.TOKEN)

func _create_selection_screen(this_enum) -> void:
	var reward_selection = REWARD_SELECT_SCENE.instantiate()
	add_child(reward_selection)
	reward_selection.connect("reward_selected",_on_reward_selected)
	reward_selection.connect("selections_satisfied",_on_selections_satisfied)
	reward_selection.open_for_level(turret_choice_level,this_enum)

	if reward_selection.has_method("popup_centered"):
		reward_selection.popup_centered()
	else:
		reward_selection.show()

func _on_reward_selected(reward: Reward) -> void:
	print(reward)
	reward_chosen.emit(reward)
	print("On Reward Selected")

func _on_selections_satisfied() -> void:
	print("On Selections Satisfied")
	get_tree().paused = false
	hide()
	queue_free()
