extends Control

@onready var amount_label : Label = %Amount
@onready var total_label : Label = %Total

@export var amount : float = 0.0
@export var total : float = 0.0
@export var color : Color

func _ready() -> void:
	amount_label.add_theme_color_override("font_color", color)
	total_label.add_theme_color_override("font_color", color)
	amount_label.text = str(amount)
	total_label.text = str(total)
	# total_label.label_settings.font_color = color

func add_amount(addition:float) -> void:
	amount_label.text = str(float(amount_label.text) + addition)

func add_total(addition:float) -> void:
	total_label.text = str(float(total_label.text) + addition)
	add_amount(addition)
