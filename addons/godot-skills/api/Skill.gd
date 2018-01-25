# A Skill is a utility for automatically mapping N effects onto M target nodes.
# Saving an arrangement of Targeters and Effects under a root Skill in a Scene enables explicit 
#     definition of algorithms for gathering and manipulating nodes using Godot's Node Hierarchy.
# Skills can be "activated". Users define what this means by implementing _activate in a derived Skill.
# Skill's Targeters individually decide whether they provide a collection of targets to the Skill
#     at time of activation or whether they only provide targets 
#     to its descendant Targeters dictates whether it automatically applies its Effects to the targets
#     that the Targeter finds (at time of activation) or whether the Effects are applied to targets as
#     the Targeter reports them via signal.

extends "signal_updater.gd"

##### CLASSES #####

##### SIGNALS #####
signal skill_activated(p_skill, p_source, p_params)                    # Skill is turned on
signal skill_deactivated(p_skill, p_source, p_params)                  # Skill is turned off
signal skill_applied(p_skill, p_source, p_target, p_params)            # Skill is directly affecting a target
signal test_target_found(p_skill, p_source, p_target_report, p_params) # For test instances of Skills

##### CONSTANTS #####
const Util = preload("godot_skills_utility.gd")
const SkillUserReport = preload("skill_user_report.gd")

##### EXPORTS #####
export var skill_name = "" setget set_skill_name, get_skill_name       # The name of the Skill, required
export var enabled = true setget set_enabled, is_enabled               # If true, the skill will proactively apply to targets
export var auto_deactivate_on_disable = true                           # If true, clearing 'enabled' will automatically call deactivate w/ p_params = {}

##### MEMBERS #####

# public
var tsid = randi() setget set_targeting_system_id, get_targeting_system_id # TargetingSystem ID: For helping descendant, non-static Targeters key into the same set of targets
var skills = [] setget , get_skills
var effects = [] setget , get_effects
var targeters = [] setget , get_targeters

# public onready

# private
var _is_active = false # Flag to prevent re-deactivation on disable if haven't activated
var _is_testing_instance = false

##### NOTIFICATIONS #####

func _init():
	is_signal_target = true
	signals_to_update = ["skill_activated", "skill_deactivated", "skill_applied", "test_target_found"]

func _ready():
	skills = get_node(skills_path)
	effects = get_node(effects_path)
	targeters = get_node(targeters_path)

##### OVERRIDES #####

##### VIRTUALS #####

# Triggers the use of this skill. Should eventually call "accept" on each target SkillUser
# - Custom Notification
# - base implemention, applies all effects to all targets immediately
#   without visualization
func _activate(p_user, p_params = {}):
	for a_target in _skill_get_targets(p_params):
		a_target.accept(p_user, self, p_params)

func _deactivate(p_user, p_params = {}):
	pass

##### PUBLIC METHODS #####

# Activates all children, activates self, then signals activation
func activate(p_source, p_params = {}):
	if not enabled: return
	for a_node in skills.get_children():
		a_node.activate(p_source, p_params)
	_activate(p_source, p_params)
	_is_active = true
	emit_signal("skill_activated", self, p_source, p_params)

# Deactivates all children, deactivates self, then signals deactivation
func deactivate(p_user, p_params = {}):
	for a_node in skills.get_children():
		a_node.deactivate(p_user, p_params)
	_deactivate(p_user, p_params)
	_is_active = false
	emit_signal("skill_deactivated", self, p_user, p_params)

# apply()
# 
# Acquires all targets from all Targeters and then applies all Effects to each target.
# 
# @param p_source      The SkillUser responsible for using this Skill.
# @param p_params      The Dictionary of parameters associated with the Skill-use.
# @param void
func apply(p_source, p_target, p_params = {}):
	for effect_node in effects.get_children():
		effect_node.apply(p_source, p_target, p_params)
	emit_signal("skill_applied", self, p_source, p_target, p_params)

# test_properties()
# 
# Runs the Skill, makes copies of desired properties, and then reverts the Skill.
# 
# @param p_source      The SkillUser responsible for using this Skill.
# @param p_props       The StringArray of properties to get tested copies of.
# @param p_params      The Dictionary of parameters associated with the Skill-use.
# @return Dictionary   The Dictionary of tested properties as key-value pairs, structured as...
# {
#     "root/path/to/node"   : { "prop1" : value1, "prop2" : value2, etc. },
#     "root/path/to/node2"  : { etc. },
# }
func test_properties(p_source, p_props = [], p_params = {}):
	# Initialize the result set.
	var result = {}
	var props = p_props
#	if props.empty():
#		props = {}
#		for effect_node in effects.get_children():
#			for a_param in effect_node.get_write_parameters():
#				props[a_param] = null
#		props = props.keys()

	# For each target, get a copy of the requested properties
	for target in _skill_get_targets(p_params):
		var report = SkillUserReport.new(target, p_props)
		for a_prop in p_props:
			report.set(target.get(a_prop))
		
		# Apply the effects, but supply the copied properties as the target's "write" variables
		for effect_node in effects.get_children():
			effect_node.apply(p_source, report, p_params)
		
		# Store the properties by path, name, or reference (in that order of priority)
		if target.is_inside_tree():
			result[target.get_path()] = report
		elif !result.has(target.get_name()):
			result[target.get_name()] = report
		else:
			result[target] = report
	
	# Return the set of all targets' requested properties
	return result

func enable():
	set_enabled(true)

func disable():
	set_enabled(false)

##### PRIVATE METHODS #####

# Utility for acquiring the skill's targets using child Targeters
func _skill_get_targets(p_params):
	var targets = {}
	var static_targeters = {}
	# Ensure that we don't end up with duplicate targets from multiple targeter sources
	for targeter_node in get_node(targeters_path).get_children():
		if targeter_node.is_static():
			if static_targeters.has(targeter_node):
				return []
			else:
				static_targeters[targeter_node] = null
		for target in targeter_node.get_targets(p_params):
			targets[target] = null
	return targets.keys()

##### CONNECTIONS #####

func _on_target_found(p_targeter, p_target):
	if _is_testing_instance:
		emit_signal("test_target_found", self, signal_target, SkillUserReport.new(p_target), {})
	else:
		apply(signal_target, p_target, {"targeter":p_targeter})

##### SETTERS AND GETTERS #####

func set_skill_name(p_skill_name):
	skill_name = p_skill_name

func get_skill_name():
	return skill_name

func set_targeting_system_id(p_tsid):
	tsid = p_tsid

func get_targeting_system_id():
	return tsid

func set_enabled(p_enable):
	enabled = p_enable
	if auto_deactivate_on_disable and not p_enable and _is_active:
		deactivate(Util.fetch_skill_user(self), {})

func is_enabled():
	return enabled
