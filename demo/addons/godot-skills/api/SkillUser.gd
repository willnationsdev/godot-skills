# SkillUsers are responsible for managing Skills and their interaction with other nodes.
# SkillUsers provide the following functionality:
# - utilities for controlling Skill ownership and availability
# - filtration of incoming and outgoing Skills
# - managing skill conditions that are associated with the SkillUser
extends Node

##### SIGNALS #####
signal condition_added(p_skill_user, p_condition)
signal condition_removed(p_skill_user, p_condition)
signal condition_triggered(p_skill_user, p_condition)
signal condition_expired(p_skill_user, p_condition)

signal skill_used(p_skill_user, p_skill, p_params)
signal skill_tested(p_skill_user, p_skill, p_props)

##### CONSTANTS #####
const Skills = preload("GodotSkillsUtility.gd")

##### EXPORTS #####

##### MEMBERS #####

##### NOTIFICATIONS #####

func _enter_tree():
	pass

func _filter_skill_input(p_source, p_skill):
	pass

func _filter_skill_output(p_source, p_skill):
	pass

##### METHODS #####

# use and accept still have kinks to work out, especially use. When we use a skill, we must put it through our filter,
# but doesn't that mean that we must then duplicate the entire skill hierarchy? Maybe. But different Skills will "activate"
# in different ways. Some may simply create a new Targeter whereas others may need to re-create their entire set of Effects
# The only way to preserve a Skill's filtered changes IS by changing its entire hierarchy though.
# But that would mean that a single Skill use might involve 6 object creations / destructions alone, just to call a few functions.
# Need a way of toggling whether it's even needed. Or maybe, if nothing matches, then the original skill reference is returned.

# @param The node of the skill to use. Typically use($skill_name)
func use(p_skill, p_params):
	var skill = _filter_skill_output(self, p_skill)
	skill.activate(self, p_params)

func accept(p_skill, p_params):
	var owner = Skills.fetch_skill_user(p_skill)
	var skill = _filter_skill_input(owner, p_skill)
	skill._skill_apply(owner, self, self, p_params)

func add_condition(p_condition):
	add_child(p_condition)
	emit_signal("condition_added", self, p_condition)

func remove_condition(p_condition):
	remove_child(p_condition)
	emit_signal("condition_removed", self, p_condition)

##### SETTERS AND GETTERS #####