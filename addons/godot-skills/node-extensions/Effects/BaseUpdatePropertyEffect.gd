extends "../../api/Effect.gd"

export(String) var property_name = ""     # The property that will be changed on the target
export(String) var max_property_name = "" # The property that represents the maximum value of the target's property
export(String) var min_property_name = "" # The property that represents the minimum value of the target's property
export(bool) var is_percentage = false    # If true and scalar, the whole number value of "delta" will be treated as a percentage
                                          # if max_property_name is set, it will be a percentage of that value. Otherwise it will
										  # be a percentage of the original value.
export(bool) var assign_directly = false  # If true, "delta" will be assigned directly. Otherwise, it is added to the original value
export(bool) var is_scalar = true         # If true, any given max/min values will be used to clamp the modified value

func _apply(p_source, p_target_read, p_target_write, p_params = {}):
	var new_value = 0.0 if assign_directly else prop_get(p_target_read, property_name)
	var temp_max_value = prop_get(p_target_read, max_property_name) if max_property_name else null
	var temp_min_value = prop_get(p_target_read, min_property_name) if min_property_name else null
	
	if is_percentage:
		if max_property_name:
			new_value += (delta * temp_max_value)
		else:
			new_value += (delta * new_value)
	else:
		new_value += float(delta)
	
	var top = temp_max_value if temp_max_value else INF
	var bottom = temp_min_value if temp_min_value else -INF
	if (max_property_name or min_property_name) and is_scalar:
		new_value = clamp(new_value, bottom, top)
	
	prop_set(p_target_write, property_name, _convert_value(new_value))

func _get_write_parameters():
	return property_name