extends "res://addons/godot-skills/api/Targeter.gd"

export(NodePath) var node_path = null

# @return Array The node at the defined path or empty array if null
func _get_targets(p_params):
    var r_targets = []
    var node = get_node(node_path)
    if node:
        r_targets.append(node)
    return r_targets

func _init():
	node_path = null

func _match_skill_user(p_skill_user):
	print("in targeter: ", get_path(), " > nodepath: ", node_path)
	var empty = null
	if node_path:
		empty = node_path.is_empty()
		if empty:
			return false
		else:
			print(node_path)
	else:
		return false
	var node = get_node(node_path)
	var result = node == p_skill_user
	print("result: ", result)
	return result