extends Node

##### CLASSES #####

##### SIGNALS #####

##### CONSTANTS #####

##### EXPORTS #####

export(NodePath) var connect_to = ""      # The node to which the designated signals will connect
export(PoolStringArray) var signals = []  # The list of signals to (dis)connect to
export(PoolStringArray) var methods = []  # The list of methods to connect each signal to, matching by index

##### MEMBERS #####

##### NOTIFICATIONS #####

func _enter_tree():
	update_signal_target(true)

func _exit_tree():
	update_signal_target(false)

##### OVERRIDES #####

##### VIRTUALS #####

##### PUBLIC METHODS #####

func update_signal_target(p_add = true):
	var target = get_parent() if not connect_to else get_node(connect_to)
	if not signals.empty() and len(signals) == len(methods):
		for a_signal in signals:
			call("connect" if p_add else "disconnect", a_signal, target, "_on_" + a_signal)

##### PRIVATE METHODS #####

##### CONNECTIONS #####

##### SETTERS AND GETTERS #####
