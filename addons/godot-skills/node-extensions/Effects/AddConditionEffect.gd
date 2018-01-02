extends "../../api/Effect.gd"

export(NodePath) var condition_path = @"condition"

func _apply(p_source, p_target_read, p_target_write, p_params = {}):
	var condition = get_node(condition_path).duplicate(Node.DUPLICATE_USE_INSTANCING | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_GROUPS)
	condition.set_creator(p_source)
	if p_target_write.has_method("add_condition"):
		p_target_write.add_condition(condition)