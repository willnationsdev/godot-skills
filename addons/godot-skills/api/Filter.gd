extends Node

##### CLASSES #####

##### SIGNALS #####

signal skill_filtered(p_filter, p_skill)

##### CONSTANTS #####

const Util = preload("godot_skills_utility.gd")

enum { FILTER_INPUT, FILTER_OUTPUT }	# Whether the Filter should check incoming or outgoing Skills

const SIGNALS = ["skill_filtered"]

##### EXPORTS #####

export(int, "Input", "Output") var filter_set = FILTER_INPUT setget set_filter_set, get_filter_set

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

# Determines whether the given skill should be modified
# @param p_source SkillUser	The original user of the skill
# @param p_skill Skill 			The skill that will be examined and possibly modified
# @return bool 					If true, the filtered skill should be modified
func _filter(p_source, p_skill):
	return true

##### PUBLIC METHODS #####

func filter(p_source, p_skill):
	if _filter(p_source, p_skill):
		for an__effect in _effects:
			if a_possible_effect.has_method("apply"):
				a_possible_effect.apply(signal_target, p_skill)
	for a_possible_filter in get_children():
		if a_possible_filter.has_method("filter"):
			a_possible_filter.filter(p_source, p_skill)

##### PRIVATE METHODS #####

##### SETTERS AND GETTERS #####
func set_filter_set(p_filter_set):
	filter_set = p_filter_set

func get_filter_set():
	return filter_set

func get_effects():
	return _effects