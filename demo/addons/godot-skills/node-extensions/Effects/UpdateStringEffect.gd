extends "UpdatePropertyEffect.gd"

export(String) var delta = ""

func _init():
	assign_directly = true
	is_scalar = false

func _convert_value(p_value):
	return p_value