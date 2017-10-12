# SkillUsers are responsible for managing Skills and their interaction with other nodes.
# SkillUsers provide the following functionality:
# - utilities for controlling Skill ownership and availability
# - filtration of incoming and outgoing Skills
# - managing skill conditions that are associated with the SkillUser
tool
extends Node

##### SIGNALS #####
signal condition_added(p_skill_user, p_condition)
signal condition_removed(p_skill_user, p_condition)

signal skill_used(p_skill_user, p_skill, p_params)
signal skill_tested(p_skill_user, p_skill, p_props)

##### CONSTANTS #####
const Filter = preload("Filter.gd")
const TargetingSystem = preload("TargetingSystem.gd")

##### EXPORTS #####
export(NodePath) var skills_path = @"skills"
export(NodePath) var filters_path = @"filters"
export(NodePath) var conditions_path = @"conditions"
export(NodePath) var duplicates_path = @"duplicates"

##### MEMBERS #####
var skills = null
var filters = null
var conditions = null
var duplicates = null

##### NOTIFICATIONS #####

func _ready():
	skills = get_node(skills_path)
	filters = get_node(filters_path)
	conditions = get_node(conditions_path)
	duplicates = get_node(duplicates_path)
	get_tree().get_root().get_node(TargetingSystem.TSName).register_skill_user(self)

func _die():
	get_tree().get_root().get_node(TargetingSystem.TSName).unregister_skill_user(self)

##### METHODS #####

# @param p_skill The node of the skill to use. Typically use($skills/skill_name)
func use(p_skill, p_params = {}):
	if not p_skill.enabled: return false
	var skill = _filter_skill_output(self, p_skill)
	get_node(duplicates_path).add_child(skill)
	print(p_skill.get_node("targeters/node_path_targeter").is_static)
	print(skill.get_node("targeters/node_path_targeter").is_static)
	skill.activate(self, p_params)
	get_node(duplicates_path).remove_child(skill)

func accept(p_user, p_skill, p_params = {}):
	var skill = _filter_skill_input(p_user, p_skill)
	get_node(duplicates_path).add_child(skill)
	skill.apply(p_user, self, p_params)
	get_node(duplicates_path).remove_child(skill)

func test(p_skill, p_params, p_props):
	var skill = _filter_skill_output(self, p_skill)
	return skill.test_properties(self, p_params, p_props)

func on_condition_triggered(p_skill_user, p_condition):
	pass

func on_condition_expired(p_skill_user, p_condition):
	pass

func on_skill_filtered(p_filter, p_skill):
	pass

func _filter_skill_input(p_skill_user, p_skill):
	return _utility_filter(p_skill_user, p_skill, Filter.FILTER_INPUT)

func _filter_skill_output(p_skill_user, p_skill):
	return _utility_filter(p_skill_user, p_skill, Filter.FILTER_OUTPUT)

func _utility_filter(p_source, p_skill, p_filter_set):
	var skill = p_skill.duplicate()
	# update them to have matching TargetingSystem IDs
	skill.tsid = p_skill.tsid
	for filter_node in filters.get_children():
		if filter_node.filter_set == p_filter_set:
			filter_node.filter(skill)
	return skill

func is_signal_target(): return true

##### SETTERS AND GETTERS #####