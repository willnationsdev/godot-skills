# A Skill is a utility for automatically mapping N effects onto N target nodes.
# Saving an arrangement of Targeters and Effects under a root Skill in a Scene enables explicit 
#     definition of algorithms for gathering and manipulating nodes using Godot's Node Hierarchy.
# Skills can be "activated" at which point they begin searching for targets.
# Skill's Targeters individually decide whether they provide a collection of targets to the Skill
#     at time of activation or whether they only provide targets 
#     to its descendant Targeters dictates whether it automatically applies its Effects to the targets
#     that the Targeter finds (at time of activation) or whether the Effects are applied to targets as
#     the Targeter reports them via signal.
extends Node

##### SIGNALS #####

##### CONSTANTS #####
const Util = preload("GodotSkillUtilities.gd")

##### EXPORTS #####
export var skill_name = "" setget set_skill_name, get_skill_name    # The name of the Skill, required

##### MEMBERS #####
var ancestor = null setget , get_ancestor   # The Skill that owns this Skill, optional, readonly
var effects = [] setget , get_effects       # cached list of descendant Effect nodes, readonly
var targeters = [] setget , get_targeters   # cached list of descendant Targeter nodes, readonly
var _testing = false                        # If true, the current application of the Skill is meant for testing. Be prepared to revert and don't emit signals

##### NOTIFICATIONS #####

# 
# - Custom Notification
# - null base implemention, to be overridden
func _activate(p_user, p_params):
    pass

##### METHODS #####

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

# TODO:
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

##### SETTERS AND GETTERS #####
func set_skill_name(p_skill_name): return (skill_name = p_skill_name)
func get_skill_name():             return skill_name
func get_ancestor():               return ancestor
func get_effects():                return effects
func get_targeters():              return targeters
