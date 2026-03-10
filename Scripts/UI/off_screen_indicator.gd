extends TextureRect

var target: Node3D

const EPSILON = 0.0001
var edge_padding: float = 0.0

func _ready() -> void:
	target.screen_entered.connect(on_screen_entered)
	target.screen_exited.connect(on_screen_exited)

func on_screen_entered():
	set_process(false)
	visible = false

func on_screen_exited():
	set_process(true)
	visible = true


func _process(_delta):
	var viewport_center : Vector2 = (get_viewport().get_visible_rect().size * 0.5) - (size/2)
	var cam_to_pos := get_viewport().get_camera_3d().to_local(target.global_transform.origin)
	var center_to_edge := Vector2(cam_to_pos.x, -cam_to_pos.y)
	var element := int(center_to_edge.abs().aspect() < viewport_center.aspect())
	center_to_edge *= viewport_center[element] / max(abs(center_to_edge[element]), EPSILON)
	position.x = viewport_center.x + center_to_edge.x
	position.y = viewport_center.y + center_to_edge.y
	rotation = center_to_edge.angle() + PI * 0.5
