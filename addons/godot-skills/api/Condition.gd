extends "signal_updater.gd"

##### CLASSES #####

##### SIGNALS #####

signal condition_triggered(p_condition) # Emitted just after the skill has been executed
signal condition_expired(p_condition)

##### CONSTANTS #####

const Util = preload("godot_skills_utility.gd")

const SIGNALS = ["condition_triggered", "condition_expired"]

##### EXPORTS #####

export(String) var condition_name = ""
export(bool) var hidden = false

##### MEMBERS #####

# public 

# public onready 

# private
var _skills = [] setget , get_skills
var _creator = null setget set_creator, get_creator

##### NOTIFICATIONS #####

func _enter_tree():
	Util.setup_condition(self, true)
	on_add()

func _exiting_tree():
	Util.setup_condition(self, false)
	on_remove()

##### OVERRIDES #####

##### VIRTUALS #####

func _get_add_parameters():
	return {}

func _get_remove_parameters():
	return {}

func _get_trigger_parameters():
	return {}

##### PUBLIC METHODS #####

func trigger():
	var dup = _get_trigger_parameters()
	dup["condition"] = self
	for a_skill in _skills:
		dup["skill"] = a_skill
		if a_skill.is_in_group("condition_trigger"):
			a_skill.activate(creator, dup.duplicate())
	emit_signal("condition_triggered", self)

func on_add():
	var dup = _get_add_parameters()
	dup["condition"] = self
	for a_skill in _skills:
		dup["skill"] = a_skill
		if a_skill.is_in_group("condition_add"):
			a_skill.activate(creator, dup.duplicate())

func on_remove():
	var dup = _get_remove_parameters()
	dup["condition"] = self
	for a_skill in _skills:
		dup["skill"] = a_skill
		if a_skill.is_in_group("condition_remove"):
			a_skill.activate(creator, dup.duplicate())

##### PRIVATE METHODS #####

##### CONNECTIONS #####

##### SETTERS AND GETTERS #####

func set_creator(p_creator):
	_creator = p_creator

func get_creator():
	return _creator
