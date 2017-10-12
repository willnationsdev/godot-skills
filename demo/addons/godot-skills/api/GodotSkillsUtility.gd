extends Reference

const Targeter = preload("Targeter.gd")

static func fetch_skill_user(p_node):
	var parent = p_node.get_parent()
	while parent and not parent is preload("SkillUser.gd"):
		parent = parent.get_parent()
	return parent

static func fetch_skill(p_node):
	var parent = p_node.get_parent()
	while parent and not parent is preload("Skill.gd"):
		parent = parent.get_parent()
	return parent
