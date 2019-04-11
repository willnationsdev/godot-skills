extends GDSServer
class_name GDSEffectServer

class UpdatePropertyRequest:
    extends GDSEffectRequest
    var property: String = ""
    var value
    func _init(p_node: Node, p_property: String, p_value):
        node = p_node
        property = p_property
        value = p_value

class UpdateGroupRequest:
    extends GDSEffectRequest
    var group: String = ""
    var persistence: bool = false
    func _init(p_node: Node, p_group: String, p_persistence):
        node = p_node
        group = p_group
        persistence = p_persistence

var ur := UndoRedo.new()

func set_property(p_request: GDSEffectRequest):
    assert p_request.target
    if ur:
        ur.create_action("Set Property")
        ur.add_do_property(p_request.node, p_request.property, p_request.value)
        ur.add_undo_property(p_request.node, p_request.property, p_request.node.get(p_request.property))
        ur.commit_action()
    else:
        p_request.node.set(p_request.property, new_value)
    
func add_to_group(p_request: GDSEffectRequest):
    assert p_request.target
    if ur:
        ur.create_action("Add Node to Group")
        ur.add_do_method(p_request.node, "add_to_group", p_request.group, p_request.persistent)
        if not p_request.node.is_in_group(p_request.group):
            ur.add_undo_method(p_request.node, "remove_from_group", p_request.group)
        ur.commit_action()
    else:
        p_request.node.add_to_group(p_request.group, p_request.persistent)

func remove_from_group(p_request: GDSEffectRequest):
    assert p_request.target
    if ur:
        ur.create_action("Add Node to Group")
        ur.add_do_method(p_request.node, "remove_from_group", p_request.node)
        if p_request.node.is_in_group(p_request.group):
            ur.add_undo_method(p_request.node, "add_to_group", p_request.group, p_request.persistent)
        ur.commit_action()
    else:
        p_request.node.remove_from_group(p_request.group)

func call_method(p_request: GDSEffectRequest):
    assert p_request.target
    assert p_request.object
    assert p_request.method
    if ur:
        pass
    else:
        match p_request.param_count:
            0, null: p_request.object.call(p_request.method)
            1: p_request.object.call(p_request.method, p_request.params[0])
            2: p_request.object.call(p_request.method, p_request.params[0], p_request.params[1])
            3: p_request.object.call(p_request.method, p_request.params[0], p_request.params[1], p_request.params[2])
            4: p_request.object.call(p_request.method, p_request.params[0], p_request.params[1], p_request.params[2], p_request.params[3])
            5: p_request.object.call(p_request.method, p_request.params[0], p_request.params[1], p_request.params[2], p_request.params[3], p_request.params[4])
            _: push_error("Too many arguments supplied for EffectServer.call_method().")