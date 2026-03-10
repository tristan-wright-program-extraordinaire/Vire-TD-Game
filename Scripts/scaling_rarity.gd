extends Node

@export var p_Common_curve: Curve
@export var p_Rare_curve: Curve
@export var p_Epic_curve: Curve
@export var p_Legendary_curve: Curve

func roll_value(power: float) -> int:
	var w0 = p_Common_curve.sample(power)
	var w1 = p_Rare_curve.sample(power)
	var w2 = p_Epic_curve.sample(power)
	var w3 = p_Legendary_curve.sample(power)

	var total = w0 + w1 + w2 + w3
	w0 /= total
	w1 /= total
	w2 /= total
	w3 /= total

	var r = randf()

	if r < w0:
		return 0
	elif r < w0 + w1:
		return 1
	elif r < w0 + w1 + w2:
		return 2
	else:
		return 3

# func _ready() -> void:
# 	var array0 = 0.0
# 	var array1 = 0.0
# 	var array2 = 0.0
# 	var array3 = 0.0
# 	for x in range(1000):
# 		var rolled_value = roll_value(power_level)
# 		if rolled_value == 0:
# 			array0 += 1
# 		if rolled_value == 1:
# 			array1 += 1
# 		if rolled_value == 2:
# 			array2 += 1
# 		if rolled_value == 3:
# 			array3 += 1

# 	print("Rolled Common: " + str(array0/10) + "%")
# 	print("Rolled Rare: " + str(array1/10) + "%")
# 	print("Rolled Epic: " + str(array2/10) + "%")
# 	print("Rolled Legendary: " + str(array3/10) + "%")
