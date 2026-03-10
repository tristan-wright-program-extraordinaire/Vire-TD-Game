class_name HUD
extends CanvasLayer

const ENUMS = preload("res://Scripts/Enums.gd")

@onready var player_state_machine: Node = %Player_State_Machine
@onready var start_button: Button = $StartButton
@onready var damage_level: Label = %Damage_Level

func _process(_delta: float) -> void:
	damage_level.text = str(Engine.get_frames_per_second())

func _on_start_button_pressed() -> void:
	pass

func _on_start_button_mouse_entered() -> void:
	pass

func _on_start_button_mouse_exited() -> void:
	pass

func _on_turret_button_mouse_entered() -> void:
	pass

func _on_turret_button_mouse_exited() -> void:
	pass
