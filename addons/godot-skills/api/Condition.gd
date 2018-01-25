extends "signal_updater.gd"

##### SIGNALS #####
signal condition_triggered(p_condition) # Emitted just after the skill has been executed
signal condition_expired(p_condition)

##### CONSTANTS #####

##### EXPORTS #####
export(String) var condition_name = "" setget set_condition_name, get_condition_name # The name of the Condition
export(NodePath) onready var on_add_skill = get_node(on_add_skill) # The Skill activated upon addition to a SkillUser
export(NodePath) onready var on_remove_skill = get_node(on_remove_skill) # The Skill activated upon removal from a SkillUser
export(NodePath) onready var on_trigger_skill = get_node(on_trigger_skill) # The Skill activated upon triggering
export(bool) var hidden = false                     # If hidden, not added to SkillUser cache

##### MEMBERS #####
var creator = null setget set_creator, get_creator  # The source SkillUser for this Condition

##### NOTIFICATIONS #####

func _init(p_creator = null):
	is_signal_target = false
	signals_to_update = ["condition_triggered", "condition_expired"]
	creator = p_creator

func _enter_tree():
	if get_parent() and get_parent().has_method("get_conditions"):
		get_parent().get_conditions().append(self)

func _exit_tree():
	if get_parent() and get_parent().has_method("get_conditions"):
		get_parent().get_conditions().erase(self)

##### METHODS #####

func trigger():
	if on_trigger_skill:
		get_node(on_trigger_skill).activate(creator, {"condition": self})
	emit_signal("condition_triggered", self)

func on_add(p_params = {}):
	var temp_params = {"condition":self}
	for a_key in p_params:
		temp_params[a_key] = p_params[a_key]
	if on_add_skill:
		get_node(on_add_skill).activate(creator, temp_params)

func on_remove(p_params = {}):
	var temp_params = {"condition":self}
	for a_key in p_params:
		temp_params[a_key] = p_params[a_key]
	if on_remove_skill:
		get_node(on_remove_skill).activate(creator, temp_params)

##### SETTERS AND GETTERS #####
func set_creator(p_creator):               creator = p_creator
func get_creator():                        return creator
func set_condition_name(p_condition_name): condition_name = p_condition_name
func get_condition_name():                 return condition_name
