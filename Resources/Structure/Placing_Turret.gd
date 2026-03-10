class_name Placing_Turret
extends Placing_Structure

const ENUMS = preload("res://Scripts/Enums.gd")

@export var glyph: ENUMS.Glyph
@export var base_range: float
@export var empowered_stats: Array[ENUMS.Stats]

