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
