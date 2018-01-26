extends "../../api/Effect.gd"

var _skills = {} setget , get_skills

var params = {}

func _apply(p_source, p_target_gitref, p_params = {}):
	get_node(skill_path).activate(p_source, params)

func get_skills():
	return _skills