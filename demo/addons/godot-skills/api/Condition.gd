extends Node

##### SIGNALS #####
signal condition_triggered(p_condition, p_skill) # Emitted just after the skill has been executed
signal ready_to_expire(p_condition)

##### CONSTANTS #####

##### EXPORTS #####
export(NodePath) var skill = null

##### MEMBERS #####

##### NOTIFICATIONS #####

func _enter_tree():
	var parent = get_parent()
	if parent:
		if "conditions" in parent.get_property_list():
			parent.conditions.append(self)
		connect("ready_to_expire", parent, "on_condition_expired")

func _exit_tree():
	var parent = get_parent()
	if parent and ("conditions" in parent.get_property_list()):
		parent.conditions.erase(self)

func _trigger():
	pass

func _expired():
	pass

##### METHODS #####

func trigger():
	_trigger()
	emit_signal("condition_triggered", self)

func expire():
	_expire()
	emit_signal("condition_expired", self)

##### SETTERS AND GETTERS #####
