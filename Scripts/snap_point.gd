class_name SnapPoint
extends Area3D

var placeable: bool = true
var restrictions: Array = []

func add_restriction(node_id):
	restrictions.append(node_id)
	placeable = len(restrictions) < 1

func remove_restriction(node_id):
	restrictions.erase(node_id)
	placeable = len(restrictions) < 1