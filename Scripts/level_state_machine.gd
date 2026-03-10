extends "res://Scripts/StateMachine.gd"

const WAVE_HUD = preload("res://Scenes/UI/WaveHUD.tscn")
const PLANNING_HUD = preload("res://Scenes/UI/PlanningHUD.tscn")

var _wave_hud = WAVE_HUD.instantiate()
var _planning_hud = PLANNING_HUD.instantiate()

func _ready():
	add_state("planning")
	add_state("wave")
	call_deferred("set_state", "planning")
	_planning_hud.connect("start_round",parent.start_round)
	
func _enter_state(new_state, _old_state):
	match new_state:
		"planning":
			print("Level Entering Planning")
			parent.develop_corruption()
			parent.add_child(_planning_hud)
			parent.current_hud = _planning_hud
		"wave":
			print("Level Entering Wave")
			parent.add_child(_wave_hud)
			parent.current_hud = _wave_hud
	state = new_state

func _exit_state(old_state, _new_state):
	match old_state:
		"planning":
			print("Level Leaving Planning")
			parent.remove_child(_planning_hud)
		"wave":
			print("Level Leaving Wave")
			parent.remove_child(_wave_hud)
