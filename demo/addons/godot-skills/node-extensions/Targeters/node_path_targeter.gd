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
	is_static = false

func _match_skill_user(p_skill_user):
	if not node_path or node_path.is_empty(): return false
	var result = get_node(node_path) == p_skill_user
	print("matching: ", p_skill_user, " > targeter: ", get_path(), " > nodepath: ", node_path, " > result: ", result)
	return result