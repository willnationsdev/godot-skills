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

extends "SignalUpdater.gd"

##### SIGNALS #####
signal target_found(p_targeter, p_target) # For REACTIVE targeting

##### CONSTANTS #####
const TargetingSystem = preload("TargetingSystem.gd")

##### EXPORTS #####
export(bool) var uses_targeting_system = false
export(bool) var is_static = true

##### MEMBERS #####

##### NOTIFICATIONS #####

func _init():
	is_signal_target = false
	signals_to_update = ["target_found"]

func _enter_tree():
	if uses_targeting_system:
		get_tree().get_root().get_node(TargetingSystem.TSName).register_targeter(self)

func _exit_tree():
	if uses_targeting_system:
		get_tree().get_root().get_node(TargetingSystem.TSName).unregister_targeter(self)

##### VIRTUALS #####

# Acquires target SkillUser nodes for this Targeter
func _get_targets(p_params):
	return []

# If uses_targeting_system, will automatically acquire target SkillUsers for which this function returns true
func _match_skill_user(p_skill_user):
	return false

##### METHODS #####

# Acquires the targets for this Targeter and its children
func get_targets(p_params):
	
	var r_targets = {} # Assures we'll have a unique list
	
	for a_possible_targeter in get_children():
		if a_possible_targeter.has_method("get_targets"):
			for target in a_possible_targeter.get_targets(p_params):
				r_targets[target] = null
	
	if uses_targeting_system:
		for target in get_tree().get_root().get_node(TargetingSystem.TSName).fetch_targets(self):
			r_targets[target] = null
	else:
		for target in _get_targets(p_params):
			r_targets[target] = null
	
	return r_targets.keys()

##### SETTERS AND GETTERS  #####
