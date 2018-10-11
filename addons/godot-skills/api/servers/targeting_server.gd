# The TargetingServer processes requests for targeting nodes
# Each method returns an array of node instances

extends Reference
class_name GDSTargetingServer

static func target_node_path(p_node: Node, p_node_path: NodePath):
    if p_node and p_node.has_node(p_node_path):
        return [p_node.get_node(p_node_path)]
    return []

static func target_group(p_source: Node, p_group):
    if not p_source:
        return []
    return p_source.get_tree().get_nodes_in_group(p_group)

