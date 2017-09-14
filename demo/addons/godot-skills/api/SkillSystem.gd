# SkillSystem is meant to be an Autoload Singleton.
# It enables all references to Skills to automatically
# use their name rather than their full path to acquire
# their script or scene.
extends Node

# how to know when a targeter has already visited.
var targeter_is_stale = []

# If p_is_stale is true, 
func get_targets(p_targeter_script, p_targeter_func):
    var group = p_targeter_script.get_path()

    # If we already have a collective target that is up-to-date, return the targeted collection
    if not targeter_is_stale[group]:
        return get_nodes_in_group(group)

    # Update the group to have all of the targets (and no other nodes)
    var nodes = get_nodes_in_group(group)
    nodes = p_targeter_func.call_func()
    targeter_is_stale[group] = false
    return nodes

    # for node in get_nodes_in_group(group):
    #     if not node in targets:
    #         node.remove_from_group(group)
    # for target in targets:
    #     if not target.is_in_group(group):
    #         target.add_to_group(group)