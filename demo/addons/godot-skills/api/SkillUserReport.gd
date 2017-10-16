extends Reference

var _skill_user = null setget set_skill_user, get_skill_user
var _report_properties = []
var _data = {} setget set_data, get_data

##### NOTIFICATIONS #####

func _init(p_skill_user, p_props = []):
	_skill_user = p_skill_user
	_report_properties = p_props
	for a_prop_name in _report_properties:
		var prop = _skill_user.get(a_prop_name)
		if typeof(prop) == TYPE_ARRAY:
			_data[a_prop_name] = Array(prop)
		elif typeof(prop) == TYPE_DICTIONARY:
			_data[a_prop_name] = Dictionary(prop)
		else:
			_data[a_prop_name] = prop

##### OVERRIDES ######

func _get(property):
	return _data[property] if property in _report_properties else _skill_user.get(property)

func _set(property, value):
	data[property] = value

##### METHODS #####

func get_stat_owner():
	return self

func get_owner():
	return _skill_user.get_owner()

##### SETTERS AND GETTERS #####
func set_skill_user(p_skill_user): pass # do nothing
func get_skill_user():             return _skill_user
func set_data(p_data):             pass # do nothing
func get_data():                   return _data