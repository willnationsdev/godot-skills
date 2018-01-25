# SkillUsers are responsible for managing Skills and their interaction with other nodes.
# SkillUsers provide the following functionality:
# - utilities for controlling Skill ownership and availability
# - filtration of incoming and outgoing Skills
# - managing skill conditions that are associated with the SkillUser

extends Node

##### SIGNALS #####
signal condition_added(p_source, p_condition)
signal condition_removed(p_source, p_condition)

signal skill_used(p_source, p_skill, p_params)
signal skill_tested(p_source, p_skill, p_params)

##### CONSTANTS #####
const Filter = preload("filter.gd")
const TargetingSystem = preload("targeting_system.gd")

##### EXPORTS #####
export(NodePath) var actor_path = @".."
export(NodePath) var stat_owner_path = @".."

##### MEMBERS #####
var skills = []
var filters = []
var conditions = []
var stat_owner = null setget set_stat_owner, get_stat_owner
var actor = null setget set_actor, get_actor

##### NOTIFICATIONS #####

func _ready():
	set_actor(get_node(actor_path))
	stat_owner = get_node(stat_owner_path)
	get_tree().get_root().get_node(TargetingSystem.TSName).register_skill_user(self)

func _die():
	get_tree().get_root().get_node(TargetingSystem.TSName).unregister_skill_user(self)

##### METHODS #####

# @param p_skill The node of the skill to use. Typically use($skills/skill_name)
func use(p_skill, p_params = {}):
	if not p_skill.is_enabled(): return false
	var skill = _filter_skill_output(self, p_skill)
	skill.activate(self, p_params)

func accept(p_user, p_skill, p_params = {}):
	var skill = _filter_skill_input(p_user, p_skill)
	skill.apply(p_user, self, p_params)

func test(p_skill, p_props, p_params = {}):
	var skill = _filter_skill_output(self, p_skill)
	return skill.test_properties(self, p_props, p_params)

func add_condition(p_condition):
	conditions.add_child(p_condition)
	p_condition.on_add()
	emit_signal("condition_added", self, p_condition)

func remove_condition(p_condition):
	conditions.remove_child(p_condition)
	p_condition.on_remove()
	emit_signal("condition_removed", self, p_condition)

func is_signal_target():
	return true

func on_skill_applied(p_skill, p_source, p_target, p_params):
	pass

func on_skill_activated(p_skill, p_source, p_params):
	pass

func on_skill_deactivated(p_skill, p_source, p_params):
	pass

func on_condition_triggered(p_target, p_condition):
	pass

func on_condition_expired(p_target, p_condition):
	pass

func on_skill_filtered(p_filter, p_skill):
	pass

func on_test_target_found(p_skill, p_source, p_target_report, p_params = {}):
	pass

func _filter_skill_input(p_source, p_skill):
	return _utility_filter(p_source, p_skill, Filter.FILTER_INPUT)

func _filter_skill_output(p_source, p_skill):
	return _utility_filter(p_source, p_skill, Filter.FILTER_OUTPUT)

func _utility_filter(p_source, p_skill, p_filter_set):
	if filters.get_children().empty(): return p_skill
	var skill = p_skill.duplicate()
	# update them to have matching TargetingSystem IDs
	skill.set_targeting_system_id(p_skill.get_targeting_system_id())
	for filter_node in filters.get_children():
		if filter_node.get_filter_set() == p_filter_set:
			filter_node.filter(skill)
	return skill

# Needed to ensure agnostic behavior with SkillUserReport for Effect.apply()
# in Skill.activate() and Skill.test_properties()
func get_skill_user():
	return self

##### SETTERS AND GETTERS #####
func set_stat_owner(p_stat_owner): stat_owner = p_stat_owner
func get_stat_owner():             return stat_owner
func set_actor(p_actor):           actor = p_actor
func get_actor():                  return actor
