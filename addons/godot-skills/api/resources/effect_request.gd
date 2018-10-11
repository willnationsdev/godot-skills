extends GDSRequest
class_name GDSEffectRequest

var node: Node = null setget set_node, get_node

func set_node(p_value: Node):
    node = p_value

func get_node() -> Node:
    return node