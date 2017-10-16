# GodotSkillsUtility is simply a collection of shared static functions
# that are helpful for nodes in the plugin.

extends Reference

const Targeter = preload("Targeter.gd")
const Skill = preload("Skill.gd")
const SkillUser = preload("SkillUser.gd")

static func fetch_skill_user(p_node):
	var ancestor = p_node.get_parent()
	while ancestor and not ancestor is SkillUser:
		ancestor = ancestor.get_parent()
	return ancestor

static func fetch_skill(p_node):
	var ancestor = p_node.get_parent()
	while ancestor and not ancestor is Skill:
		ancestor = ancestor.get_parent()
	return ancestor

static func prop_get(p_obj, p_prop_name):
	if typeof(p_obj) == TYPE_DICTIONARY:
		return p_obj[p_prop_name]
	elif typeof(p_obj) == TYPE_OBJECT:
		return p_obj.get(p_prop_name)
	return null

static func prop_set(p_obj, p_prop_name, p_value):
	if typeof(p_obj) == TYPE_DICTIONARY:
		p_obj[p_prop_name] = p_value
	elif typeof(p_obj) == TYPE_OBJECT:
		p_obj.set(p_prop_name, p_value)