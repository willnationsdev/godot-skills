# A Skill is a utility for automatically mapping N effects onto M target nodes.
# Saving an arrangement of Targeters and Effects under a root Skill in a Scene enables explicit 
#     definition of algorithms for gathering and manipulating nodes using Godot's Node Hierarchy.
# Skills can be "activated". Users define what this means by implementing _activate in a derived Skill.
# Skill's Targeters individually decide whether they provide a collection of targets to the Skill
#     at time of activation or whether they only provide targets 
#     to its descendant Targeters dictates whether it automatically applies its Effects to the targets
#     that the Targeter finds (at time of activation) or whether the Effects are applied to targets as
#     the Targeter reports them via signal.
extends Node

##### SIGNALS #####
signal skill_activated(p_skill, p_source, p_params)                 # Skill is turned on
signal skill_deactivated(p_skill, p_source, p_params)               # Skill is turned off
signal skill_applied(p_skill, p_source, p_params, p_target)         # Skill is directly affecting a target

##### CONSTANTS #####
const Types = preload("GodotSkillsTypes.gd")

##### EXPORTS #####
export var skill_name = "" setget set_skill_name, get_skill_name    # The name of the Skill, required
export var enabled = true setget set_enabled, is_enabled            # If true, the skill will proactively apply to targets
export var auto_deactivate_on_disable = true                        # If true, clearing 'enabled' will automatically call deactivate w/ p_params = {}

##### MEMBERS #####
var skills = [] setget , get_skills                    # cached list of child Skill nodes, readonly
var effects = [] setget , get_effects                  # cached list of child Effect nodes, readonly
var targeters = [] setget , get_targeters              # cached list of child Targeter nodes, readonly
var owner = null setget , get_owner                    # The owner of this skill
var _testing = false                                   # True = Skill is testing properties. Will revert. Don't emit signals.

##### NOTIFICATIONS #####

# Add self to parent Skill's cache of Skill children, if needed
# Fetch owner, if it exists
func _enter_tree():
	_add_to_parent_cache()
	owner = _fetch_skill_user_owner()

# Remove self from parent Skill's cache of Skill children, if needed
func _exit_tree():
	_remove_from_parent_cache()

# Triggers the use of this skill. Should eventually call "apply"
# - Custom Notification
# - base implemention, applies all effects to all targets immediately
#   without visualization
func _activate(p_user, p_params):
	var targets = _skill_get_targets()
	_skill_apply(targets)

func _deactivate(p_user, p_params):
	pass

##### METHODS #####

# Activates all children, activates self, then signals activation
func activate(p_user, p_params):
	if not enabled: return
	for child in get_children():
		if child is Types.Skill:
			child.activate(p_user, p_params)
	_update_targeter_connections(get_children(), true)
	_activate(p_user, p_params)
	emit_signal("skill_activated", self, p_user, p_params)

# Deactivates all children, deactivates self, then signals deactivation
func deactivate(p_user, p_params):
	if not enabled: return
	for child in get_children():
		if child is Types.Skill:
			child.deactivate(p_user, p_params)
	_update_targeter_connections(get_children(), false)
	_deactivate(p_user, p_params)
	emit_signal("skill_deactivated", self, p_user, p_params)

# apply()
# 
# Acquires all targets from all Targeters and then applies all Effects to each target.
# 
# @param p_user        The SkillUser responsible for using this Skill.
# @param p_params      The Dictionary of parameters associated with the Skill-use.
# @param void
func apply(p_user, p_params):
	if not (enabled or _testing): return
	var targets = _skill_get_targets()
	_skill_apply_(targets)

# revert()
# 
# Acquires all targets from all Targeters and then reverts all Effects on each target.
# 
# @param p_user        The SkillUser responsible for using this Skill.
# @param p_params      The Dictionary of parameters associated with the Skill-use.
# @param void
func revert(p_user, p_params):
	if not _testing: return
	var targets = _skill_get_targets()
	_skill_revert(targets)

func on_target_found(p_targeter, p_target, p_params):
	p_params["target"] = p_target
	activate(get_owner(), p_params)

# test_properties()
# 
# Runs the Skill, makes copies of desired properties, and then reverts the Skill.
# 
# @param p_user        The SkillUser responsible for using this Skill.
# @param p_params      The Dictionary of parameters associated with the Skill-use.
# @param p_props       The StringArray of properties to get tested copies of.
# @return Dictionary   The Dictionary of tested properties as key-value pairs, structured as...
# {
#     "root/path/to/node"   : { "prop1" : value1, "prop2" : value2, etc. },
#     "root/path/to/node2"  : { etc. },
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

func enable(): enabled = true       # for convenience
func disable(): enabled = false     # for convenience

# Utility for acquiring the skill's targets using child Targeters
func _skill_get_targets():
	var targets = {}
	# Ensure that we don't end up with duplicate targets from multiple targeter sources
	for targeter in targeters:
		for target in targeter.get_targets():
			targets[target] = null
	return targets.keys()

# Utility for applying the skill's effects using child Effects
func _skill_apply(p_targets):
	for target in p_targets:
		for effect in effects:
			effect.apply(p_user, target)
		if not _testing:
			emit_signal("skill_applied", self, p_user, p_target)

# Utility for reverting the skill's effects using child Effects
func _skill_revert(p_targets):
	for target in p_targets:
		for effect in effects:
			effect.revert(p_user, target)

# Utility for acquiring the "owner" (usually a SkillUser or another Skill)
func _fetch_skill_user_owner():
	var parent = get_parent()
	while parent and not parent is preload("SkillUser.gd"):
		parent = parent.get_parent()
	return parent

# Utility for adding this Skill to a parent Skill's cache of child Skills
func _add_to_parent_cache():
	var parent = get_parent()
	if parent and ("skills" in parent.get_property_list()):
		parent.skills.append(self)

# Utility for removing this Skill from a parent Skill's cache of child Skills
func _remove_from_parent_cache():
	var parent = get_parent()
	if parent and parent is get_script():
		parent.skills.erase(self)

func _update_targeter_connections(p_targeters, p_connect = true):
	for targeter in p_targeters:
		if not targeter is preload("Targeter.gd"): return
		if p_connect:
			targeter.connect("target_found", self, "on_target_found")
		else:
			targeter.disconnect("target_found", self, "on_target_found")
		_connect_to_targeter_children(targeter.targeters, p_connect)

##### SETTERS AND GETTERS #####
func set_skill_name(p_skill_name): skill_name = p_skill_name
func get_skill_name():             return skill_name
func get_skill():                  return skill
func get_effects():                return effects
func get_targeters():              return targeters
func is_enabled():                 return enabled

func set_enabled(p_enable):
	enabled = p_enable
	if auto_deactivate_on_disable and not p_enable:
		deactivate(get_owner(), {})
