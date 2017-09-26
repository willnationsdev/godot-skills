extends Reference

static func fetch_ancestors(p_node):
	if p_node extends "Effect.gd":
		return _fetch_ancestors_for_effects(p_node)
	elif p_node extends "Targeter.gd":
	    return _fetch_ancestors_for_targeters(p_node)
	elif p_node extends "Skill.gd":
	    return _fetch_ancestors_for_skills(p_node)
	else:
		return null

static func _fetch_ancestors_for_effects(p_node):
	var ancestor_skill = p_node
	var ancestor_effect = p_node
	while ancestor_skill and not ancestor_skill extends "Skill.gd":
		ancestor_skill = p_node.get_parent()
		if not ancestor_effect extends "Effect.gd":
			ancestor_effect = p_node.get_parent()
	p_node.set_ancestors(ancestor_skill, ancestor_effect)
	if ancestor_skill:
		ancestor_skill.effects[] = p_node
		p_node.ancestor_skill = ancestor_skill
	if ancestor_effect:
		ancestor_effect.effects[] = p_node
		p_node.ancestor_effect = ancestor_effect
	return ancestor_skill

static func _fetch_ancestors_for_targeters(p_node):
	var ancestor_skill = p_node
	var ancestor_targeter = p_node
	while ancestor_skill and not ancestor_skill extends "Skill.gd":
		ancestor_skill = p_node.get_parent()
		if not ancestor_targeter extends "Targeter.gd":
			ancestor_targeter = p_node.get_parent()
	p_node.set_ancestors(ancestor_skill, ancestor_targeter)
	if ancestor_skill:
		ancestor_skill.targeters[] = p_node
		p_node.ancestor_skill = ancestor_skill
	if ancestor_targeter:
		ancestor_targeter.targeters[] = p_node
		p_node.ancestor_targeter = ancestor_targeter
	return ancestor_skill

static func _fetch_ancestors_for_skills(p_node):
	var ancestor_skill = p_node
	while ancestor_skill and not ancestor_skill extends "Skill.gd":
		ancestor_skill = p_node.get_parent()
	p_node.set_ancestors(ancestor_skill)
	if ancestor_skill:
		ancestor_skill.skills[] = p_node
		p_node.ancestor_skill = ancestor_skill
	return ancestor_skill