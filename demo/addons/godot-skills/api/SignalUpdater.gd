extends Node

##### CLASSES #####

##### SIGNALS #####

##### CONSTANTS #####

##### EXPORTS #####
export var is_signal_target = false setget , is_signal_target           # If true, all descendant nodes' signals will connect to functions on this node

##### MEMBERS #####
var signal_target = null setget set_signal_target, get_signal_target    # The node to which all descendants' signals will connect functions
var signals_to_update = []                                              # The list of signals to (dis)connect on the signal_target

##### NOTIFICATIONS #####

func _enter_tree():
	update_signal_target(true)

func _exit_tree():
	update_signal_target(false)

##### OVERRIDES #####

##### VIRTUALS #####

##### PUBLIC METHODS #####

# (dis)connects method(s) in the signal_target if one exists.
func update_signal_target(p_add = true):
	var ancestor = get_parent()

	# Find a signal_target. If one exists, cache it and (dis)connect given signals
	if not signals_to_update.empty():
		while ancestor and not (ancestor.has_method("is_signal_target") and ancestor.is_signal_target()):
			ancestor = ancestor.get_parent()
		if ancestor:
			set_signal_target(ancestor)
			for a_signal in signals_to_update:
				call("connect" if p_add else "disconnect", a_signal, signal_target, "on_" + a_signal)

##### PRIVATE METHODS #####

##### SETTERS AND GETTERS #####
func set_signal_target(p_signal_target): signal_target = p_signal_target
func get_signal_target(): return signal_target
func is_signal_target(): return is_signal_target