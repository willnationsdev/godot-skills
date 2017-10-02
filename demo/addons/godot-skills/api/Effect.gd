# Effects are the Node-ification of the Functor concept, i.e. a function as an object.
# Effects "apply" an effect, potentially using member variables set in advance as context.
# Effects can be attached underneath Skill nodes for compositional construction of algorithms
# in a Scene. They can also be attached underneath other Effects, in which case they are
# executed prior to that Effect.
# 
# Examples of an Effect may include...
# UpdatePropertyEffect:  Given a min, max, delta, and is_percentage, adds a value to a named property on the target.
#                        target.set(prop, target.get(prop) + (value = clamp(delta * max if is_percentage else delta, min, max))
# UpdateGroupEffect:     Adds or removes a given SkillUser from the named group.
# TriggerSkillEffect:    Activates a Skill when the Effect is applied. The source of the Skill matches the Effect's.
#                        The Skill in question can be attached as a child of the Effect.
# AddConditionEffect:    Creates a Condition and adds it to the target SkillUser's list of Conditions
# RemoveConditionEffect: Given a Condition, a number of instances (-1 for all) of that Condition are removed from the target SkillUser's list of Conditions.
extends Node

##### SIGNALS #####

##### CONSTANTS #####
const Skills = preload("GodotSkillsUtility.gd")

##### EXPORTS #####

##### MEMBERS #####
var effects = []		# The child Effects owned by this Effect, optional. Will automatically apply prior to this.

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
# @param p_source SkillUser                   Who instigated the Skill
# @param p_target_read SkillUser              The owner of properties that will be read from
# @param p_target_write SkillUser|Dictionary  The owner of properties that will be written to
# @param p_params Dictionary                  The parameters for the Skill that are defined at time of activation
func _apply(p_source, p_target_read, p_target_write, p_params):
	pass

# Notifies others of which properties will be overwritten for testing purposes
# @return StringArray The names of the properties on the target that will be written to
func _get_write_parameters():
	return []

##### METHODS #####

# Applies all child effects on the target and then its own effect.
# DO NOT REPLACE
func apply(p_source, p_target_read, p_target_write, p_params):
	for child in effects:
		child.apply(p_source, p_target_read, p_target_write, p_params)
	_apply(p_source, p_target_read, p_target_write, p_params)

##### SETTERS AND GETTERS #####