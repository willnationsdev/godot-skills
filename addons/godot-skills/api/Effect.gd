# Effects are the Node-ification of the Functor concept, i.e. a function as an object.
# Effects "apply" an effect, potentially using member variables set in advance as context.
# Effects can be attached underneath...
# - Skill nodes for modifying sets of SkillUser nodes.
# - Filter nodes for modifying filtered Skill nodes.
# - other Effect nodes where they are executed prior to their parent.
# 
# Examples of an Effect may include...
# UpdatePropertyEffect:   Given a min, max, delta, and is_percentage, adds a value to a named property on the target.
#                         target.set(prop, target.get(prop) + (value = clamp(delta * max if is_percentage else delta, min, max))
# UpdateGroupEffect:      Adds or removes a given SkillUser from the named group.
# TriggerSkillEffect:     Activates a Skill when the Effect is applied. The source of the Skill matches the Effect's.
#                         The Skill in question can be attached as a child of the Effect.
# AddConditionEffect:     Creates a Condition and adds it to the target SkillUser's list of Conditions
# TriggerConditionEffect: Triggers the activation of a Condition attached to the target SkillUser.
# RemoveConditionEffect:  Given a Condition, a number of instances (-1 for all) of that Condition are removed from the target SkillUser's list of Conditions.
extends Node

##### CLASSES #####

##### SIGNALS #####

##### CONSTANTS #####

const Util = preload("godot_skills_utility.gd")
const SIGNALS = []

##### EXPORTS #####

##### MEMBERS #####

# public

# public onready

# private
var _effects = [] setget , get_effects

##### NOTIFICATIONS #####

func _enter_tree():
	Util.setup(self, true)

func _exit_tree():
	Util.setup(self, false)

##### OVERRIDES #####

##### VIRTUALS #####

# Applies some change from a source to a target
# @param p_source SkillUser                   Who instigated the Skill
# @param p_target_report SkillUserReport      A report on the target SkillUser.
# @param p_params Dictionary                  The parameters for the Skill that are defined at time of activation
func _apply(p_source, p_target_gitref, p_params):
	pass

##### PUBLIC METHODS #####

# Applies all child effects on the target and then its own effect.
func apply(p_source, p_target_gitref, p_params):
	for a_possible_effect in get_children():
		if a_possible_effect.has_method("apply"):
			a_possible_effect.apply(p_source, p_target_gitref, p_params)
	_apply(p_source, p_target_gitref, p_params)

##### PRIVATE METHODS #####

##### SETTERS AND GETTERS #####

func get_effects():
	return _effects