extends GDSRequest
class_name GDSEffectRequest

var target: Node = null setget set_target, get_target

func set_target(p_value: Node):
    target = p_value

func get_target() -> Node:
    return target