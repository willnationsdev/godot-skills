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
const Skills = preload("GodotSkillsUtility.gd")

##### EXPORTS #####
export var skill_name = "" setget set_skill_name, get_skill_name    # The name of the Skill, required
export var enabled = true setget set_enabled, is_enabled            # If true, the skill will proactively apply to targets
export var auto_deactivate_on_disable = true                        # If true, clearing 'enabled' will automatically call deactivate w/ p_params = {}

##### MEMBERS #####
var skills = [] setget , get_skills                    # cached list of child Skill nodes, readonly
var effects = [] setget , get_effects                  # cached list of child Effect nodes, readonly
var targeters = [] setget , get_targeters              # cached list of child Targeter nodes, readonly
var _is_active = false                                 # Flag to prevent re-deactivation on disable if haven't activated

##### NOTIFICATIONS #####

# Add self to parent Skill's cache of Skill children, if needed
func _enter_tree():
	_add_to_parent_cache()

# Remove self from parent Skill's cache of Skill children, if needed
func _exit_tree():
	_remove_from_parent_cache()

# Triggers the use of this skill. Should eventually call "accept" on each target SkillUser
# - Custom Notification
# - base implemention, applies all effects to all targets immediately
#   without visualization
func _activate(p_user, p_params):
	for target in _skill_get_targets():
		target.accept(p_user, self, p_params)

func _deactivate(p_user, p_params):
	pass

##### METHODS #####

# Activates all children, activates self, then signals activation
func activate(p_user, p_params):
	if not enabled: return
	for skill in skills:
		skill.activate(p_user, p_params)
	_activate(p_user, p_params)
	_is_active = true
	emit_signal("skill_activated", self, p_user, p_params)

# Deactivates all children, deactivates self, then signals deactivation
func deactivate(p_user, p_params):
	for skill in skills:
		skill.deactivate(p_user, p_params)
	_deactivate(p_user, p_params)
	_is_active = false
	emit_signal("skill_deactivated", self, p_user, p_params)

# apply()
# 
# Acquires all targets from all Targeters and then applies all Effects to each target.
# 
# @param p_user        The SkillUser responsible for using this Skill.
# @param p_params      The Dictionary of parameters associated with the Skill-use.
# @param void
func apply(p_user, p_target, p_params):
	for effect in effects:
		effect.apply(p_user, p_target, p_target, p_params)
	emit_signal("skill_applied", self, p_user, p_target)

func on_target_found(p_targeter, p_target):
	apply(Skills.fetch_skill_user(self), p_target, {"targeter":p_targeter})

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
	# Initialize the result set.
	var result = {}

	# For each target, get a copy of the requested properties
	for target in _skill_get_targets(p_params):
		var prop_copies = {}
		for prop in p_props:
			prop_copies[prop] = target.get(prop)
		
		# Apply the effects, but supply the copied properties as the target's "write" variables
		for effect in effects:
			effect.apply(p_user, target, prop_copies, p_params)
		
		# Store the properties by path, name, or reference (in that order of priority)
		if target.is_inside_tree():
			result[target.get_path()] = prop_copies
		elif !result.has(target.get_name()):
			result[target.get_name()] = prop_copies
		else:
			result[target] = prop_copies
	
	# Return the set of all targets' requested properties
	return result

func enable(): set_enabled(true)       # for convenience
func disable(): set_enabled(false)     # for convenience

# Utility for acquiring the skill's targets using child Targeters
func _skill_get_targets(p_params):
	var targets = {}
	# Ensure that we don't end up with duplicate targets from multiple targeter sources
	for targeter in targeters:
		for target in targeter.get_targets(p_params):
			targets[target] = null
	return targets.keys()

# Utility for adding this Skill to a parent's Skill cache
func _skill_add_to_parent_cache():
	var parent = get_parent()
	if parent and ("skills" in parent.get_property_list()):
		parent.skills.append(self)

# Utility for removing this Skill from a parent's Skill cache
func _skill_remove_from_parent_cache():
	var parent = get_parent()
	if parent and ("skills" in parent.get_property_list()):
		parent.skills.erase(self)

##### SETTERS AND GETTERS #####
func set_skill_name(p_skill_name): skill_name = p_skill_name
func get_skill_name():             return skill_name
func get_skill():                  return skill
func get_effects():                return effects
func get_targeters():              return targeters
func is_enabled():                 return enabled

func set_enabled(p_enable):
	enabled = p_enable
	if auto_deactivate_on_disable and not p_enable and _is_active:
		deactivate(Skills.fetch_skill_user(self), {})
