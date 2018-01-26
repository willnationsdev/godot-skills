# The base type for effects which update properties on other nodes.
extends "../../api/effect.gd"

enum {
	OPERATION_ADD=0, # Delta will be added to the property
	OPERATION_ASSIGN=1 # Delta will be assigned directly to the property
}

enum {
	DELTA_TYPE_STRING=0
	DELTA_TYPE_INT=1
	DELTA_TYPE_REAL=2
	DLETA_TYPE_BOOL=3
	DLETA_TYPE_NODE_PATH=4
}

export(String) var property_name = ""     # The property that will be changed on the target
export(String) var max_property_name = "" # The property that represents the maximum value of the target's property
export(String) var min_property_name = "" # The property that represents the minimum value of the target's property
export(bool) var is_percentage = false    # If true and scalar, the whole number value of "delta" will be treated as a percentage.
                                          # If max_property_name is set, it will be a percentage of that value. Otherwise it will
										  # be a percentage of the original value.
export(int, PROPERTY_HINT_ENUM, "Add,Assign") var operation = OPERATION_ADD # The operation this effect will perform on the property
export(String) var delta
export(int, PROPERTY_HINT_ENUM, "String,int,real,bool,NodePath") var type = DELTA_TYPE_STRING # The type of the delta value

func _apply(p_source, p_target_gitref, p_params = {}):
	var new_value = null
	var max_value = null
	var min_value = null

	match type:
		DELTA_TYPE_STRING:
			match operation:
				OPERATION_ADD:
					new_value = p_target_gitref.fetch(property_name)
					new_value += delta
				OPERATION_ASSIGN:
					new_value = delta
		DELTA_TYPE_INT:
			match operation:
				OPERATION_ADD:
					if is_percentage:
						new_value = p_target_gitref.fetch(property_name)
						if max_property_name:
							new_value += (int(delta) * temp_max_value)
						else:
							new_value += (int(delta) * new_value)
					else:
						new_value = p_target_gitref.fetch(property_name)
						new_value += int(delta)
				OPERATION_ASSIGN:
					if is_percentage:
						if max_property_name:
							new_value = (int(delta) * temp_max_value)
						else:
							new_value = (int(delta) * new_value)
					else:
						new_value = int(delta)
		DELTA_TYPE_REAL:
			match operation:
				OPERATION_ADD:
					if is_percentage:
						new_value = p_target_gitref.fetch(property_name)
						new_value += float(delta)
					else:
						new_value = p_target_gitref.fetch(property_name)
						new_value += float(delta)
				OPERATION_ASSIGN:
					if is_percentage:
						new_value = float(delta)
					else:
						new_value = float(delta)
		DELTA_TYPE_BOOL:
			match operation:
				OPERATION_ADD:
					new_value = p_target_gitref.fetch(property_name)
					new_value += delta
				OPERATION_ASSIGN:
					new_value = delta
		DELTA_TYPE_NODE_PATH:
			match operation:
				OPERATION_ADD:
					new_value = p_target_gitref.fetch(property_name)
					new_value += NodePath(delta)
				OPERATION_ASSIGN:
					new_value = NodePath(delta)
		
	if max_property_name:
		max_value = p_target_gitref.fetch(max_property_name)
	else:
		max_value = INF
	if min_property_name:
		min_value = p_target_gitref.fetch(min_property_name)
	else:
		min_value = -INF
	
	if (max_property_name or min_property_name) and is_scalar():
		new_value = clamp(new_value, float(min_value), float(max_value))
		if type == DELTA_TYPE_INT:
			new_value = floor(new_value)
	
	p_target_gitref.stage(property_name, new_value)

func is_scalar():
	match type: DELTA_TYPE_INT, DELTA_TYPE_REAL: return true
	return false