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
signal skill_activated(p_skill, p_source, p_params)                 # Skill is turned on
signal skill_applied(p_skill, p_source, p_params, p_target)         # Skill is directly affecting a target

##### CONSTANTS #####

##### EXPORTS #####
export var skill_name = "" setget set_skill_name, get_skill_name    # The name of the Skill, required
export var active = true setget set_active, is_active               # If true, the skill will proactively apply to targets

##### MEMBERS #####
var skills = [] setget , get_skills                    # cached list of child Skill nodes, readonly
var effects = [] setget , get_effects                  # cached list of child Effect nodes, readonly
var targeters = [] setget , get_targeters              # cached list of child Targeter nodes, readonly
var _testing = false                                   # True = Skill is testing properties. Will revert. Don't emit signals.

##### NOTIFICATIONS #####

# Add self to parent Skill's cache of Skill children, if needed
func _enter_tree():
	var parent = get_parent()
	if parent and parent is get_script():
        parent.skills.append(self)

# Remove self from parent Skill's cache of Skill children, if needed
func _exit_tree():
    var parent = get_parent()
    if parent and parent is get_script():
        parent.skills.erase(self)

# Triggers the use of this skill.
# - Custom Notification
# - null base implemention, to be overridden
func _activate(p_user, p_params):
	pass

##### METHODS #####

func activate(p_user, p_params):
	active = true
	_activate(p_user, p_params)
	emit_signal("skill_activated", self, p_user, p_params)

# Acquires all targets from all Targeters and then applies all Effects to each target.
# DO NOT REPLACE
func apply(p_user, p_params):
	if not (active or _testing): return
    var targets = _skill_get_targets()
    _skill_apply_(targets)

# Acquires all targets from all Targeters and then reverts all Effects on each target.
# DO NOT REPLACE
func revert(p_user, p_params):
	if not _testing: return
    var targets = _skill_get_targets()
    _skill_revert(targets)

# Applies all effects to all targets.
# Then acquires all desired properties from each target.
# The properties are compiled into a Dictionary of Dictionaries.
# Then all effects are reverted on each target.
# Finally, the Dictionary of property key-value pairs is returned:
# {
#     "root/path/to/node"   : { "prop1" : value1, "prop2" : value2, etc. },
#     "root/path/to/node2"  : etc.
# }
func test_properties(p_user, p_params, p_props):
    # Set testing flag, get targets, and apply effects to them.
    _testing = true
    var targets = _skill_get_targets()
    _skill_apply(targets)

    # Initialize the result set.
    var result = {}

    # For each target, save their node path as a key if they are in the tree.
    for target in targets:
        if target.is_inside_tree():
            var path = target.get_path()
            result[path] = {}

            # Get the target's property names.
            var props = target.get_property_list()

            # For each property we want, if the target has that property,
            # save that property at target_node_path/property_name.
            for prop in p_props:
                if prop in props:
                    result[path][prop] = target.get(prop)
    
    # Return targets to normal. Clear testing flag (since we are done) and
    # return tested properties.
    _skill_revert(targets)
    _testing = false
    return result

func enable(): active = true       # for convenience
func disable(): active = false     # for convenience

func _skill_get_targets():
    var targets = {}
    # Ensure that we don't end up with duplicate targets from multiple targeter sources
    for targeter in targeters:
        for target in targeter.get_targets():
            targets[target] = null
    return targets.keys()

func _skill_apply(p_targets):
	for target in p_targets:
		for effect in effects:
			effect.apply(p_user, target)
		if not _testing:
            emit_signal("skill_applied", self, p_user, p_target)

func _skill_revert(p_targets):
	for target in targets:
		for effect in effects:
			effect.revert(p_user, target)


##### SETTERS AND GETTERS #####
func set_skill_name(p_skill_name): skill_name = p_skill_name
func set_active(p_enable_active):  active = p_enable_active
func get_skill_name():             return skill_name
func get_skill():                  return skill
func get_effects():                return effects
func get_targeters():              return targeters
func is_active():                  return active
