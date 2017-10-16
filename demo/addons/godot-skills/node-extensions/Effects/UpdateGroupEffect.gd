extends "../../api/Effect.gd"

enum { ADD_TO_GROUP, REMOVE_FROM_GROUP }

export(String) var group_name = ""     # The property that will be changed on the target
export(int, "Add", "Remove") var action = ADD_TO_GROUP
export(bool) var persistent = false

func _apply(p_source, p_target_read, p_target_write, p_params = {}):
	if action == ADD_TO_GROUP:
		p_target_read.add_to_group(group_name, persistent)
	elif action == REMOVE_FROM_GROUP:
		p_target_read.remove_from_group(group_name)