extends "BaseUpdatePropertyEffect.gd"

export(int) var delta = 0

func _convert_value(p_value):
	return int(floor(p_value))