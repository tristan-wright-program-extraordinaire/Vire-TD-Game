extends ColorRect

signal start_game()

@onready var start_button: Button = $MarginContainer/HBoxContainer/MenuOptions/StartButton

func _on_start_button_pressed() -> void:
	start_game.emit()
