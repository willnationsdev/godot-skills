extends "../../api/Effect.gd"

export(NodePath) var skill_path = @"skill"

var params = {}

func _apply(p_source, p_target_read, p_target_write, p_params = {}):
	get_node(skill_path).activate(p_source, params)