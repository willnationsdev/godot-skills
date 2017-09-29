# SkillUsers are responsible for managing Skills and their interaction with other nodes.
# SkillUsers provide the following functionality:
# - utilities for controlling Skill ownership and availability
# - filtration of incoming and outgoing Skills
# - managing skill conditions that are associated with the SkillUser
tool
extends Node

##### SIGNALS #####
signal used_skill(p_user, p_skill, p_params)
signal accepted_skill(p_user, p_skill, p_params)
signal tested_skill(p_user, p_skill, p_params, p_result)

##### CONSTANTS #####
const Filter = preload("Filter.gd")

##### EXPORTS #####

##### MEMBERS #####
var conditions = {} # condition_reference : number_of_instances
var output_filter = null
var input_filter = null

##### NOTIFICATIONS #####

# Automatically generates child filters if none exist (tool required)
func _enter_tree():
	if not input_filter:
		input_filter = Filter.new()
		add_child(input_filter)
	if not output_filter:
		output_filter = Filter.new()
		add_child(output_filter)

##### METHODS #####

# @param p_skill The node of the skill to use. Typically use($skill_name, {...})
# @param p_params The parameters to pass along to the Skill and its filtrations
# @return void
func use(p_skill, p_params):
	var skill = output_filter.filter(p_skill, p_params)
	skill.activate(self, p_params)
	emit_signal("used_skill", self, skill, p_params)

# @param p_skill The node of the skill to use. Typically test_properties($skill_name, {...}, [...])
# @param p_params The parameters to pass along to the Skill and its filtrations
# @param p_props The names of the properties to fetch after testing
# @return Dictionary The tested property names mapped to their values
func test_properties(p_skill, p_params, p_props):
	var skill = output_filter.filter(p_skill, p_params)
	var result = skill.test_properties(self, p_params, p_props)
	emit_signal("tested_skill", self, skill, p_params, result)
	return result

# @param p_skill The node of the skill to use. Typically accept(skill_node.skill_name, {...})
# @param p_params The parameters passed along with the Skill
# @return void
func accept(p_skill, p_params):
	var skill = input_filter.filter(p_skill, p_params)
	p_params["target"] = self
	skill.apply(skill.get_owner(), p_params)
	emit_signal("accepted_skill", self, skill, p_params)

##### SETTERS AND GETTERS #####