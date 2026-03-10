extends CanvasLayer

@onready var labels = {
	ENUMS.Element.FIRE : %Fire_Kindle,
	ENUMS.Element.WATER : %Water_Kindle,
	ENUMS.Element.GRASS : %Grass_Kindle,
	ENUMS.Element.ELECTRIC : %Electric_Kindle,
	ENUMS.Element.GROUND : %Ground_Kindle,
}

func add_amount(element:int,addition:float) -> void:
	labels[element].add_amount(addition)

func add_total(element:int,addition:float) -> void:
	labels[element].add_total(addition)