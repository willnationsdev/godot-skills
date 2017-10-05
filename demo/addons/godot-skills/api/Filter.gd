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
	_update_parent(true)

# Remove self from parent's Skill cache, if needed
func _exit_tree():
	_update_parent(false)

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

func _update_parent(p_enter):
	var parent = get_parent()
	if parent and ("skills" in parent.get_property_list()):
		if p_enter:
			parent.skills.append(self)
		else:
			parent.skills.erase(self)

##### SETTERS AND GETTERS #####