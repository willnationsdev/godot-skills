# SkillCriteria are just a means of testing whether a Skill matches some criteria.
# If it does, then it applies some effect to it.
extends Node

##### SIGNALS #####
signal criteria_evaluated(p_criteria, p_target, p_result)

##### CONSTANTS #####
enum { POLICY_AND, POLICY_OR, POLICY_ONLY_1 }

##### EXPORTS #####
export(int, "AND", "OR", "1 Only" ) var policy = POLICY_AND
export(bool) var not_result = false

##### MEMBERS #####
var criteria = []		# The child Criteria owned by this Criteria, optional. Will automatically check prior to this.
var effects = []		# The child Effect owned by this Criteria, optional. Will automatically apply to objects meeting criteria.

##### NOTIFICATIONS #####

# Updates parent Effect cache
func _enter_tree():
	get_parent().criteria.append(self)

# Updates parent Effect cache
func _exit_tree():
	get_parent().criteria.erase(self)

# Tests whether the node meets the criteria
# - Custom Notification
func _match(p_node):
	pass

##### METHODS #####

func _criteria_match(p_node, p_matched_effects):
	var result = true
	# check children criteria
	for crit in criteria:
		if policy == POLICY_AND:
			result &= crit._criteria_match(p_node, p_matched_effects)
			if not result: return false
		elif policy == POLICY_OR:
			result |= crit._criteria_match(p_node, p_matched_effects)
		elif policy == POLICY_ONLY_1:
			result += crit._criteria_match(p_node, p_matched_effects)
			if result > 1: return false
	# check this criteria
	if policy == POLICY_AND:
		result &= _match(p_node)
	elif policy == POLICY_OR:
		result |= _match(p_node)
	elif policy == POLICY_ONLY_1:
		result += _match(p_node)
	# check for only-1 policy
	if policy == POLICY_ONLY_1 and result != 1:
		result = false
	# add associated effects
	if result: p_matched_effects += effects
	return result

func get_matched_effects(p_node):
	var effects = []
	_criteria_match(p_node, effects)
	return effects
