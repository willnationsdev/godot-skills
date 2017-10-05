# Targeters are responsible for locating SkillUsers that meet given criteria.
# They may update manually with every request for targets or automatically 
#     as SkillUsers are added or removed from the tree.
# All depends on the criteria sought after and what the most efficient algorithm
#     is for locating nodes based on that criteria.
#
# Examples of a Targeter may include...
# Area2DTargeter: A scene with an Area2D root is instanced and attached
#                 to the node at the given NodePath and stored as a variable.
#                 Signals for area_entered and body_entered are then relayed to
#                 target_found connections for the Targeter
extends Node

##### SIGNALS #####
signal target_found(p_targeter, p_target) # For REACTIVE targeting

##### CONSTANTS #####
const Skills = preload("GodotSkillsUtility.gd")

##### EXPORTS #####

##### MEMBERS #####
var targeters = []          # Cached list of child Targeter nodes
var _targets = []           # For optional caching of PROACTIVE targeting

##### NOTIFICATIONS #####

# Updates parent Targeter cache
func _enter_tree():
	get_parent().targeters.append(self)
	connect("target_found", Skills.fetch_skill(self), "on_target_found")

# Updates parent Targeter cache
func _exit_tree():
	get_parent().targeters.erase(self)
	disconnect("target_found", Skills.fetch_skill(self), "on_target_found")

# Custom Notification
# null base implementation, to be overridden
# Acquires targets for this Targeter
func _get_targets(p_params):
	pass

##### METHODS #####

# Acquires the targets for this Targeter and its children
func get_targets(p_params):
	var r_targets = {} # Assures we'll have a unique list

	for child in _child_targeters:
		for target in child.get_targets():
			r_targets[target] = null

	for target in _get_targets():
		r_targets[target] = null

	return r_targets.keys()

##### SETTERS AND GETTERS  #####