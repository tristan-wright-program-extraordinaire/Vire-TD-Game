extends Node3D

@onready var CARD = preload("res://Scenes/Card.tscn")
@onready var cursor = %Cursor

@export var cards : Array[Node3D]

@export var card_spacing: float = 0.5
@export var arc_angle: float = 30.0 # degrees
@export var card_lift: float = 0.1
# @export var selected_z_offset: float = 0.5
@export var face_speed: float = 5.0

# @export var starting_cards_count : int

var is_animating: bool = false
var curr_selected_index: int = 0

# func _ready() -> void:
# 	var hand_layout = get_hand_layout(starting_cards_count)
# 	for i in range(starting_cards_count):
# 		var this_card = CARD.instantiate()
# 		this_card.position = hand_layout[i].position
# 		this_card.rotation = hand_layout[i].rotation
# 		add_child(this_card)
# 		cards.append(this_card)

func _arrange_cards(selected_index: int,put_away: bool):
	if cards.size() > 0:
		curr_selected_index = selected_index
		var hand_layout = get_hand_layout(cards.size(),selected_index,put_away)
		var tween = create_tween()
		for i in cards.size():
			var card = cards[i]
			var target = hand_layout[i]
			tween.parallel().tween_property(card, "position", target.position, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(card, "rotation", target.rotation, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		tween.finished.connect(func(): is_animating = false)

func _add_card(reward:Reward) -> void:
	var this_card = CARD.instantiate()
	this_card.reward = reward
	add_child(this_card)
	cards.append(this_card)
	_arrange_cards(curr_selected_index,false)

func show_hand():
	if cards.size() > 0:
		_arrange_cards(curr_selected_index,true)
		create_tween().tween_property(self, "position:y", -1.25, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		cursor.selected_card = cards[0]

func hide_hand():
	cursor.card_area = null
	_arrange_cards(curr_selected_index,false)
	create_tween().tween_property(self, "position:y", -1.5, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func get_hand_layout(card_count: int, new_index: int = 0, put_away: bool = false) -> Array[Dictionary]:
	var selected_index = abs(new_index)
	var x_range = [1.3,-1.3]
	var x_buffer = (x_range[0] - x_range[1]) / (card_count + 1)

	var x_range_selected = [1.15,-1.15]
	var x_selected_buffer = (x_range_selected[0] - x_range_selected[1]) / (card_count + 1)
	var x_selected_location = x_range_selected[0] - (x_selected_buffer * (selected_index + 1))

	var left_buffer: float
	var right_buffer: float

	var rotation_range = [12,78]

	var left_rotation: float = 0.0
	var left_rotation_start: float = 0.0
	var left_start_index: int = 0

	var right_rotation: float = 0.0
	var right_rotation_start: float = 0.0
	var right_start_index: int = 0

	var selected_rotation: float = 15.0 * x_selected_location

	if (card_count + 1) / 2.0 > (selected_index + 1):
		left_buffer = x_buffer * 0.35
		right_buffer = x_buffer * 0.65
		left_rotation = (rotation_range[1] - rotation_range[0]) / (selected_index + 1)
		left_rotation_start = selected_rotation + rotation_range[0]
		right_rotation = (rotation_range[1] - rotation_range[0]) / (card_count - selected_index)
		right_rotation_start = rotation_range[0]
		right_start_index = 1
	elif (card_count + 1) / 2.0 < (selected_index + 1):
		left_buffer = x_buffer * 0.65
		right_buffer = x_buffer * 0.35
		left_rotation = (rotation_range[1] - rotation_range[0]) / (selected_index + 1)
		left_rotation_start = rotation_range[0]
		right_rotation = (rotation_range[1] - rotation_range[0]) / (card_count - selected_index)
		right_rotation_start = selected_rotation + rotation_range[0]
		left_start_index = 1
	else:
		left_buffer = x_buffer * 0.5
		right_buffer = x_buffer * 0.5
		left_rotation = (rotation_range[1] - rotation_range[0]) / (selected_index + 1)
		left_rotation_start = rotation_range[0]
		right_rotation = (rotation_range[1] - rotation_range[0]) / (card_count - selected_index)
		right_rotation_start = rotation_range[0]

	var return_arr: Array[Dictionary] = []
	for i in range(card_count):
		var x_location = x_selected_location
		var z_location = -0.2
		var y_location = 0.5
		var y_rotation = deg_to_rad(selected_rotation)
		if selected_index > i:
			x_location = x_selected_location + ((x_buffer * (selected_index - i)) + left_buffer)
			z_location = 0.0
			y_location = 0.0
			y_rotation = deg_to_rad((left_rotation * (selected_index - i + left_start_index)) + left_rotation_start)
		elif selected_index < i:
			x_location = x_selected_location - ((x_buffer * (i - selected_index)) + right_buffer)
			z_location = 0.0
			y_location = 0.0
			y_rotation = deg_to_rad(-right_rotation_start - (right_rotation * (i - selected_index + right_start_index)))
			# y_rotation = deg_to_rad(-45)
		if !put_away:
			# z_location = 0.0
			y_location = 0.0
		
		return_arr.append({
			"position": Vector3(x_location,y_location,z_location),
			"rotation": Vector3(0.0,y_rotation,0.0)
		})

	return return_arr
