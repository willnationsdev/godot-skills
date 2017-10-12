# A Skill is a utility for automatically mapping N effects onto M target nodes.
# Saving an arrangement of Targeters and Effects under a root Skill in a Scene enables explicit 
#     definition of algorithms for gathering and manipulating nodes using Godot's Node Hierarchy.
# Skills can be "activated". Users define what this means by implementing _activate in a derived Skill.
# Skill's Targeters individually decide whether they provide a collection of targets to the Skill
#     at time of activation or whether they only provide targets 
#     to its descendant Targeters dictates whether it automatically applies its Effects to the targets
#     that the Targeter finds (at time of activation) or whether the Effects are applied to targets as
#     the Targeter reports them via signal.
extends "SignalUpdater.gd"

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
export(NodePath) var skills_path = @"skills"                        # The path to the node which owns all of the Skill nodes for this Skill
export(NodePath) var effects_path = @"effects"                      # The path to the node which owns all of the Effect nodes for this Skill
export(NodePath) var targeters_path = @"targeters"                  # The path to the node which owns all of the Targeter nodes for this Skill

##### MEMBERS #####
var _is_active = false              # Flag to prevent re-deactivation on disable if haven't activated
var tsid = randi()  				# TargetingSystem ID: For helping descendant, non-static Targeters key into the same set of targets
var skills = null
var effects = null
var targeters = null

##### NOTIFICATIONS #####

func _init():
	is_signal_target = true
	signals_to_update = get_signal_list()

func _ready():
	print('skill ready')
	skills = get_node(skills_path)
	effects = get_node(effects_path)
	targeters = get_node(targeters_path)

##### VIRTUALS #####

# Triggers the use of this skill. Should eventually call "accept" on each target SkillUser
# - Custom Notification
# - base implemention, applies all effects to all targets immediately
#   without visualization
func _activate(p_user, p_params):
	for a_target in _skill_get_targets(p_params):
		a_target.accept(p_user, self, p_params)

func _deactivate(p_user, p_params):
	pass

##### METHODS #####

# Activates all children, activates self, then signals activation
func activate(p_user, p_params = {}):
	if not enabled: return
	for a_node in get_node(skills_path).get_children():
		a_node.activate(p_user, p_params)
	_activate(p_user, p_params)
	_is_active = true
	emit_signal("skill_activated", self, p_user, p_params)

# Deactivates all children, deactivates self, then signals deactivation
func deactivate(p_user, p_params):
	for a_node in skills.get_children():
		a_node.deactivate(p_user, p_params)
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
	for effect_node in effects.get_children():
		effect_node.apply(p_user, p_target, p_target, p_params)
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
		for effect_node in effects.get_children():
			effect_node.apply(p_user, target, prop_copies, p_params)
		
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
	var static_targeters = {}
	# Ensure that we don't end up with duplicate targets from multiple targeter sources
	for targeter_node in get_node(targeters_path).get_children():
		if targeter_node.is_static:
			if static_targeters.has(targeter_node):
				return []
			else:
				static_targeters[targeter_node] = null
		for target in targeter_node.get_targets(p_params):
			targets[target] = null
	return targets.keys()

##### SETTERS AND GETTERS #####
func set_skill_name(p_skill_name): skill_name = p_skill_name
func get_skill_name():             return skill_name
func is_enabled():                 return enabled

func set_enabled(p_enable):
	enabled = p_enable
	if auto_deactivate_on_disable and not p_enable and _is_active:
		deactivate(Skills.fetch_skill_user(self), {})
