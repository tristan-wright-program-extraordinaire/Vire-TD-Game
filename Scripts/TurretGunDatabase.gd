extends Node

var database : Dictionary = {}

func _ready():
	for i in range(ENUMS.Element.size()):
		database[i] = {}
		for j in range(ENUMS.Glyph.size()):
			var this_element = ENUMS.Element.find_key(i)
			var this_glyph = ENUMS.Glyph.find_key(j)
			var path = "res://Resources/TurretGuns/TurretGun_%s_%s.tres" % [this_element, this_glyph]
			print(path)
			database[i][j] = load(path)