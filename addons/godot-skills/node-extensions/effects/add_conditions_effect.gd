# Adds a Condition to a SkillUser.
# Conditions trigger other skills when certain conditions are met.
extends "../../api/Effect.gd"

var _conditions = {} setget , get_conditions # this will enable conditions to automatically hook up to this Effect.

func _apply(p_source, p_target, p_params = {}):
	for a_condition in _conditions:
		a_condition.set_creator(p_source)
		if p_target.has_method("add_condition"):
			p_target.add_condition(a_condition)

func get_conditions():
	return _conditions