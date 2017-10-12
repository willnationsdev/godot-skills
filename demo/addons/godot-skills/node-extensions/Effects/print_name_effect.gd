extends "res://addons/godot-skills/api/Effect.gd"

func _apply(p_source, p_target_read, p_target_write, p_params):
	print(p_source.get_name(), " is applying a print_name_effect on ", p_target_read.get_name(), " with params: ", p_params)
