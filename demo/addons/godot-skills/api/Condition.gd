extends "SignalUpdater.gd"

##### SIGNALS #####
signal condition_triggered(p_condition) # Emitted just after the skill has been executed
signal condition_expired(p_condition)

##### CONSTANTS #####

##### EXPORTS #####
export(NodePath) var on_add_skill_path = null       #The Skill activated upon addition to a SkillUser
export(NodePath) var on_remove_skill_path = null    #The Skill activated upon removal from a SkillUser
export(NodePath) var on_trigger_skill_path = null   #The Skill activated upon triggering
export(bool) var hidden = false                     #if hidden, not added to SkillUser cache

##### MEMBERS #####
var on_add_skill = null
var on_remove_skill_path = null
var on_trigger_skill_path = null
var creator = null # The source SkillUser for this Condition

##### NOTIFICATIONS #####

func _init():
	is_signal_target = false
	signals_to_update = ["condition_triggered", "condition_expired"]

func _enter_tree():
	if on_add_skill:
		get_node(on_add_skill).activate(creator, {"condition": self})
	if get_parent().has_user_signal("condition_added"):
		get_parent().emit_signal("condition_added", get_parent(), self)

func _exit_tree():
	if on_remove_skill:
		get_node(on_remove_skill).activate(creator, {"condition": self})
	if get_parent().has_user_signal("condition_removed"):
		get_parent().emit_signal("condition_removed", get_parent(), self)

##### METHODS #####

func trigger():
	if on_trigger_skill:
		get_node(on_trigger_skill).activate(creator, {"condition": self})
	emit_signal("condition_triggered", self)

##### SETTERS AND GETTERS #####
