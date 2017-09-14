extends "res://addons/godot-skills/api/Targeter.gd"

export(NodePath) var node_path = ""

func _enter_tree():
    static = true

# @return Array The node at the defined path or empty array if null
func _target():
    var node = get_node(node_path)
    return [node] if node else []