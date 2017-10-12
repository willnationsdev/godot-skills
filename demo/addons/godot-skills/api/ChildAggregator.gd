extends Node

export var is_signal_target = false setget , is_signal_target			# If true, all descendant nodes' signals will connect to functions on this node
var signal_target = null setget set_signal_target, get_signal_target	# The node to which all descendants' signals will connect functions

# (dis)connects method(s) in the signal_target if one exists.
func update_signal_target(p_add = true, p_signals = []):
	var ancestor = get_parent()
	
	# Find a signal_target. If one exists, cache it and (dis)connect given signals
	if not p_signals.empty():
		while ancestor and not ancestor.is_signal_target():
			ancestor = ancestor.get_parent()
		if ancestor:
			set_signal_target(ancestor)
			for a_signal in p_signals:
				call("connect" if p_add else "disconnect", a_signal, signal_target, "on_" + a_signal)

func set_signal_target(p_signal_target): signal_target = p_signal_target
func get_signal_target(): return signal_target
func is_signal_target(): return is_signal_target