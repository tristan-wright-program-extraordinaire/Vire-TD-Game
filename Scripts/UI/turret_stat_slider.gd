extends Control

signal value_changed(stat,value)

const ENUMS = preload("res://Scripts/Enums.gd")

@export var stat: ENUMS.Stats
@export var stat_left_text: String = "Stat"
@export var stat_right_text: String = "Stat"

@onready var slider: HSlider = %HSlider
@onready var stat_left: Label = %StatLeft
@onready var stat_value: Label = %StatValue
@onready var stat_right: Label = %StatRight
@onready var value_left: Label = %ValueLeft
@onready var value_center: Label = %ValueCenter
@onready var value_right: Label = %ValueRight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stat_left.text = stat_left_text
	stat_right.text = stat_right_text
	pass # Replace with function body.

func _on_h_slider_value_changed(value:float) -> void:
	value_changed.emit(stat,value)
	stat_value.text = str(value)