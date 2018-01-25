# The TargetingSystem keeps track of every SkillUser that enters or exits
# the active scene. Through it, Targeters that opt-in to using it can
# simply examine every SkillUser as the scene state changes rather than
# each one having find and examine all SkillUsers themselves.

extends Node

##### CLASSES #####

##### SIGNALS #####

##### CONSTANTS #####
const Util = preload("godot_skills_utility.gd")
const TSName = "targeting_system"

##### EXPORTS #####

##### MEMBERS #####

# public
var matchers = {}
var skill_users = {}

# public onready

# private

##### NOTIFICATIONS #####

func _ready():
	var config = ConfigFile.new()
	if config.load("res://addons/godot-skills/godot-skills.cfg") == OK:
		TSName = config.get_value("targeting_system", "name", "targeting_system")
	else:
		TSName = "targeting_system"

##### OVERRIDES #####

##### VIRTUALS #####

##### PUBLIC METHODS #####

func register_skill_user(p_skill_user):
	print("registering: ", p_skill_user)
	for a_key in matchers:
		var match_set = matchers[a_key]
		if match_set.match_func.call_func(p_skill_user):
			match_set.targets[p_skill_user] = null
	skill_users[p_skill_user] = null

func unregister_skill_user(p_skill_user):
	for a_key in matchers:
		matchers[a_key].targets.erase(p_skill_user)
	skill_users.erase(p_skill_user)

func register_targeter(p_targeter):
	var match_func= funcref(p_targeter, "_match_skill_user")
	var existing_targets = {}
	for a_skill_user in skill_users:
		if match_func.call_func(a_skill_user):
			existing_targets[a_skill_user] = null
	matchers[_get_targeter_key(p_targeter)] = {
		"match_func": match_func,
		"targets": existing_targets
	}

func unregister_targeter(p_targeter):
	matchers.erase(_get_targeter_key(p_targeter))

func fetch_targets(p_targeter):
	var match_set = matchers[_get_targeter_key(p_targeter)]
	return match_set.targets.keys() if match_set else []

##### PRIVATE METHODS #####

func _get_targeter_key(p_targeter):
	if p_targeter.is_static:
		return p_targeter.get_script().get_path()
	else:
		var skill = Util.fetch_skill(p_targeter)
		return str(skill.get_targeting_system_id()) + str(skill.get_path_to(p_targeter))

##### CONNECTIONS #####

##### SETTERS AND GETTERS #####

