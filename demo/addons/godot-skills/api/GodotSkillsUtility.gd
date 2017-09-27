# DEPRECATED

extends Reference

const Effect = preload("Effect.gd")
const Targeter = preload("Targeter.gd")
const Skill = preload("Skill.gd")

static func fetch_ancestor_skill(p_node):
	var ancestor_skill = p_node.get_parent()
	while ancestor_skill and not ancestor_skill is Skill:
		ancestor_skill = ancestor_skill.get_parent()
	if ancestor_skill:
		return ancestor_skill
	return null

static func get_skill_system():
	return get_node("/skill_system")

static func Effect():
	return Effect

static func Targeter():
	return Targeter

static func Skill():
	return Skill