extends Node

const Skills = preload("GodotSkillsUtility.gd")
const TSName = "targeting_system"

var matchers = {}

func register_skill_user(p_skill_user):
	for key in matchers:
		var match_set = matchers[key]
		if match_set.match_func.call_func(p_skill_user):
			match_set.targets[p_skill_user] = null

func unregister_skill_user(p_skill_user):
	for key in matchers:
		matchers[key].targets.erase(p_skill_user)

func register_targeter(p_targeter):
	matchers[_get_targeter_key(p_targeter)] = {
		"match_func": funcref(p_targeter, "_match_skill_user"),
		"targets": {}
	}

func unregister_targeter(p_targeter):
	matchers.erase(_get_targeter_key(p_targeter))

func fetch_targets(p_targeter):
	var match_set = matchers[_get_targeter_key(p_targeter)]
	return match_set.targets.keys() if match_set else []

func _get_targeter_key(p_targeter):
	if p_targeter.is_static:
		return p_targeter.get_script().get_path()
	else:
		var skill = Skills.fetch_skill(p_targeter)
		return str(skill.tsid) + str(skill.get_path_to(p_targeter))

static func get_instance():
	var config = ConfigFile.new()
	if not config.load("res://godot_skills.cfg") == OK:
		if not config.load("res://addons/godot-skills/godot_skills.cfg") == OK:
			return get_node("/root/targeting_system")