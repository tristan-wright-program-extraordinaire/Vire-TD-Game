extends Node3D

@onready var main_menu: ColorRect = $"Main Menu"

const LEVEL = preload("res://Scenes/Level.tscn")

var currentLevel = null

func _ready() -> void:
	currentLevel = LEVEL.instantiate()
	
func _on_main_menu_start_game() -> void:
	main_menu.visible = false
	add_child(currentLevel)
