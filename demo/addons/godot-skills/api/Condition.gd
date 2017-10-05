extends Node

##### SIGNALS #####
signal triggered(p_condition, p_skill) # Emitted just after the skill has been executed
signal expired(p_condition)

##### CONSTANTS #####

##### EXPORTS #####
export(NodePath) var skill = null		#For design-time creation of conditions
export(bool) var hidden = false			#if hidden, not added to SkillUser cache

##### MEMBERS #####

##### NOTIFICATIONS #####

func _enter_tree():
	_update_parent(true)

func _exit_tree():
	_update_parent(false)

##### METHODS #####

func _update_parent(p_enter):
	var parent = get_parent()
	if parent and !hidden:
		if "conditions" in parent.get_property_list():
			call("connect" if p_enter else "disconnect", "expired", parent, "on_condition_expired")

##### SETTERS AND GETTERS #####
