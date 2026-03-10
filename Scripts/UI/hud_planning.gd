extends "res://Scripts/UI/hud.gd"

signal start_round

@onready var hand_area: Control = %Hand_Area

var hovered: bool = false

func _on_start_button_pressed() -> void:
	print("START ROUND")
	start_round.emit()

func _on_hand_area_mouse_exited() -> void:
	hovered = false
	if get_parent().cursor.state_machine.state == "picking_card":
		hand_area.scale.y = 1
		get_parent().cursor.hand.hide_hand()
		get_parent().cursor.state_machine.set_state("watching")

func _on_hand_area_mouse_entered() -> void:
	hovered = true
	if get_parent().cursor.state_machine.state == "watching" and get_parent().cursor.hand.cards.size() > 0:
		_hand_hover()

func _hand_hover() -> bool:
	if hovered and get_parent().cursor.hand.cards.size() > 0:
		hand_area.scale.y = 1.6
		get_parent().cursor.hand.show_hand()
		get_parent().cursor.state_machine.set_state("picking_card")
		return hovered
	else:
		return false
