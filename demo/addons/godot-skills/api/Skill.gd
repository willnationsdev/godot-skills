# A Skill is a utility for automatically mapping N effects onto N target nodes.
# Saving an arrangement of Targeters and Effects under a root Skill in a Scene enables explicit 
#     definition of algorithms for gathering and manipulating nodes using Godot's Node Hierarchy.
extends Node

# signals
signal skill_applied(p_skill, p_source, p_params)

# public

var ancestor = null setget , get_ancestor   # The Skill that owns this Skill, optional, readonly
var effects = [] setget , get_effects       # cached list of descendant Effect nodes, readonly
var targeters = [] setget , get_targeters   # cached list of descendant Targeter nodes, readonly

export var skill_name = "" setget set_skill_name, get_skill_name    # The name of the Skill, required

# Acquires all targets from all Targeters and then applies all Effects to each target.
# DO NOT REPLACE
func apply(p_user, p_params):
    var targets = []
    for targeter in targeters:
        targets += targeter.get_targets()
    for target in targets:
        for effect in effects:
            effect.apply(p_user, target)
        if not _testing:
            emit_signal("skill_applied", self, p_user, p_target)

# Acquires all targets from all Targeters and then reverts all Effects on each target.
# DO NOT REPLACE
func revert(p_user, p_params):
    var targets = []
    for targeter in targeters:
        targets += targeter.get_targets()
    for target in targets:
        for effect in effects:
            effect.revert(p_user, target)
    if _testing:
        _testing = false

# Applies all effects to all targets.
# Then acquires all desired properties from each target.
# The properties are compiled into a Dictionary of Dictionaries.
# Then all effects are reverted on each target.
# Finally, the Dictionary of property key-value pairs is returned:
# {
#     "root/path/to/node"   : { "prop1" : value1, "prop2" : value2, etc. },
#     "root/path/to/node2"  : etc.
# }
func test_properties(p_source, p_target, p_props):
    pass

# Basic Getters and Setters
func set_skill_name(p_skill_name): return (skill_name = p_skill_name)
func get_skill_name():             return skill_name
func get_ancestor():               return ancestor
func get_effects():                return effects
func get_targeters():              return targeters

var _testing = false            # If true, the current application of the Skill is meant for testing. Be prepared to revert and don't emit signals