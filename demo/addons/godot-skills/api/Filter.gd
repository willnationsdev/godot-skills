extends Node

##### SIGNALS #####

##### CONSTANTS #####

##### EXPORTS #####

##### MEMBERS #####
var filters = []		# The child Filters owned by this Filter, optional. Will automatically use after this, without duplicating.

##### NOTIFICATIONS #####

# Add self to parent's Filter cache, if needed
# Fetch owner, if it exists
func _enter_tree():
	_add_to_parent_cache()

# Remove self from parent's Skill cache, if needed
func _exit_tree():
	_remove_from_parent_cache()

# Applies some change to the node, ideally only if it meets certain criteria
# @param p_node Node The node that will be examined and possibly modified
# @return void
# - Custom Notification
# - base implementation, to be overridden
func _filter(p_node):
	pass

##### METHODS #####

func filter(p_node):
	var node = p_node.duplicate(false)
	_filter(node)
	for filter in filters:
		filter._filter(node)
	return node

# Utility for adding this Skill to a parent Skill's cache of child Skills
func _add_to_parent_cache():
	var parent = get_parent()
	if parent and ("skills" in parent.get_property_list()):
		parent.skills.append(self)

# Utility for removing this Skill from a parent Skill's cache of child Skills
func _remove_from_parent_cache():
	var parent = get_parent()
	if parent and ("skills" in parent.get_property_list()):
		parent.skills.erase(self)

##### SETTERS AND GETTERS #####