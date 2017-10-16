# A collection of shared static functions for the plugin's nodes

extends Reference

##### CLASSES #####

##### SIGNALS #####

##### CONSTANTS #####
const Skill = preload("Skill.gd")
const SkillUser = preload("SkillUser.gd")

##### EXPORTS #####

##### MEMBERS #####

##### NOTIFICATIONS #####

##### OVERRIDES #####

##### VIRTUALS #####

##### PUBLIC METHODS #####

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

##### PRIVATE METHODS #####

##### SETTERS AND GETTERS #####