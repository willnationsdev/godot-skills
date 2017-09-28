# Effects are the Node-ification of the Functor concept, i.e. a function as an object.
# Effects "apply" an effect, potentially using member variables set in advance as context.
# Effects can be attached underneath Skill nodes for compositional construction of algorithms
# in a Scene. They can also be attached underneath other Effects, in which case they are
# executed prior to that Effect.
# 
# Examples of an Effect may include...
# DamageEffect:         Subtracts an "amount" from a property on the target. The default property name is "health".
#                       Has boolean "percentage": if true, "amount" is multiplied against the property and then subtracted (100 subtracts all).
# RestoreEffect:        Adds an "amount" to a property on the target, but not more than some maximum value. The 
#                       default values for the property and max property are "health" and "max_health", respectively.
#                       Has boolean "percentage": if true, "amount" is multiplied against the max property and then added (100 restores all).
# TriggerSkillEffect:   Activates a Skill when the Effect is applied. The source of the Skill matches the Effect's.
#                       The Skill in question can be attached as a child of the Effect.
# 
# 
extends Node

##### SIGNALS #####
signal effect_applied(p_effect, p_source, p_target, p_params)

##### CONSTANTS #####

##### EXPORTS #####

##### MEMBERS #####
var effects = []		# The child Effects owned by this Effect, optional. Will automatically apply prior to this.
var _testing = false 	# If true, the current application of the Effect is meant for testing. Be prepared to revert and don't emit signals.

##### NOTIFICATIONS #####

# Updates parent Effect cache
func _enter_tree():
	get_parent().effects.append(self)

# Updates parent Effect cache
func _exit_tree():
	get_parent().effects.erase(self)

# Applies some change from a source to a target
# - Custom Notification
# - null base implementation, to be overridden
func _apply(p_source, p_target, p_params):
	pass

# Reverts a change previously applied from a source to a target
# - Custom Notification
# - null base implementation, to be overridden
func _revert(p_source, p_target, p_params):
	pass

##### METHODS #####

# Applies all child effects on the target and then its own effect.
# DO NOT REPLACE
func apply(p_source, p_target, p_params):
	for child in _child_effects:
		child.apply(p_source, p_target, p_params)
	_apply(p_source, p_target, p_params)
	if not _testing:
		emit_signal("effect_applied", self, p_source, p_target, p_params)

# Reverts its effect on the target and then reverts all child effects.
# DO NOT REPLACE
func revert(p_source, p_target, p_params):
	_revert(p_source, p_target, p_params)
	for child in _child_effects:
		child.revert(p_source, p_target, p_params)
	if _testing:
		_testing = false

##### SETTERS AND GETTERS #####