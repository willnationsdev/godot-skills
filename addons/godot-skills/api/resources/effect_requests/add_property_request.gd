extends GDSEffectRequest
class_name GDSAddPropertyRequest

# exported values
export(String) var property := "" setget set_property
export(float) var min_value := 0.0
export(float) var max_value := INF
export(PercentageType) var is_percentage := PERCENT_NONE setget set_is_percentage
export(bool) var is_clamped := true

# assigned values
var delta setget set_delta # could be several types

# computed values
var value setget set_value

func set_is_percentage(p_value: int):
	is_percentage = p_value
	if is_percentage:
		if max_value == INF:
			match delta_type:
				TYPE_INT:
					max_value = 100
				TYPE_REAL:
					max_value = 100.0
				_:
					pass
	else:
		if round(max) == 100:
			max_value = INF

func set_node(p_value: Node):
	node = p_value
	_update_value()

func set_delta(p_value):
	delta = p_value
	delta_type = typeof(delta)
	match delta_type:
		TYPE_INT, TYPE_REAL:
			pass
		_:
			self.is_percentage = PERCENT_NONE

func set_property(p_value: String):
	property = p_value
	_update_value()

func is_type_ok():
	var type = typeof(value)
	var delta_type = typeof(delta)
	match type:
		TYPE_NIL, TYPE_OBJECT:
			return delta_type == TYPE_OBJECT or delta_type == TYPE_NIL
		_:
			return type == delta_type

func _update_value():
	if node:
		value = node.get(property)
		type = typeof(value)
	else:
		value = null
		type = TYPE_NIL
	match type:
		TYPE_INT, TYPE_REAL:
			pass
		_:
			is_percentage = PERCENT_NONE
			is_clamped = false