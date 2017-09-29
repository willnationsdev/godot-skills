# SkillFilters are nodes that apply child Effect nodes to a
extends Node

enum { FILTER_INPUT, FILTER_OUTPUT }

var criteria = []		# The child Criteria owned by this Filter, optional. Will use on filtered nodes

export(int, "Input", "Output") var filter_type = FILTER_INPUT

func _enter_tree():
	if filter_type == FILTER_INPUT:
		get_parent().input_filter = self
	elif filter_type == FILTER_OUTPUT:
		get_parent().output_filter = self

func filter(p_node, p_params):
	var node_tree = p_node.duplicate(true)
	for crit in critera:
		for effect in crit.get_matched_effects(node_tree):
			effect.apply(get_parent(), node_tree, p_params)
	return node_tree

