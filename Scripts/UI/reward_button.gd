class_name RewardButton
extends Button

signal reward_button_pressed

const ENUMS = preload("res://Scripts/Enums.gd")

var reward: Reward

func _update_labels(_new_reward) -> void:
	pass


func _on_button_up() -> void:
	reward_button_pressed.emit(reward,self)
	print(reward)
	print("BUTTON PRESSED")
