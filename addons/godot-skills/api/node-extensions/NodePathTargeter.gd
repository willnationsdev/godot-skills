extends "../Targeter.gd"

export(NodePath) var node_path = ""

# @return Array The node at the defined path or empty array if null
func get_targets():
    var node = get_node(node_path)
    return [node] if node else []