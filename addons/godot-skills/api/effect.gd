# Effects are the Node-ification of the Functor concept, i.e. a function as an object.
# Effects "apply" an effect, potentially using member variables set in advance as context.
# Effects can be attached underneath...
# - Skill nodes for modifying sets of SkillUser nodes.
# - Filter nodes for modifying filtered Skill nodes.
# - other Effect nodes where they are executed prior to their parent.
# 
# Examples of an Effect may include...
# UpdatePropertyEffect:   Given a min, max, delta, and is_percentage, adds a value to a named property on the target.
#                         target.set(prop, target.get(prop) + (value = clamp(delta * max if is_percentage else delta, min, max))
# UpdateGroupEffect:      Adds or removes a given SkillUser from the named group.
# TriggerSkillEffect:     Activates a Skill when the Effect is applied. The source of the Skill matches the Effect's.
#                         The Skill in question can be attached as a child of the Effect.
# AddConditionEffect:     Creates a Condition and adds it to the target SkillUser's list of Conditions
# TriggerConditionEffect: Triggers the activation of a Condition attached to the target SkillUser.
# RemoveConditionEffect:  Given a Condition, a number of instances (-1 for all) of that Condition are removed from the target SkillUser's list of Conditions.
tool
extends Node

##### CLASSES #####

##### SIGNALS #####

##### CONSTANTS #####

enum Type = {
	NIL,
	ADD_PROPERTY,
	ASSIGN_PROPERTY,
	INVERT_PROPERTY,
	ADD_TO_GROUP,
	REMOVE_FROM_GROUP
}

enum PercentageType {
	PERCENT_NONE=0,
	PERCENT_RELATIVE=1,
	PERCENT_ABSOLUTE=2
}

const SIGNALS = []

##### EXPORTS #####

export(Type) var type = NIL

##### MEMBERS #####

# public

# public onready

# private
var _effects: Array = [] setget , get_effects

var _node: Node = null
var _property: String = ""
var _delta
var _value
var _is_clamped: bool = true
var _min: float = 0.0
var _max: float = INF
var _is_percentage: bool = false

var _group: String = ""
var _persistent: bool = false

##### NOTIFICATIONS #####

func _notification(p_what: int):
	match p_what:
		NOTIFICATION_PARENTED:
			GDSUtility.setup(self, true)
		NOTIFICATION_UNPARENTED:
			GDSUtility.setup(self, false)

##### OVERRIDES #####

func get_configuration_warning():
    match type:
        ADD_PROPERTY, ASSIGN_PROPERTY, INVERT_PROPERTY:
            if not _property:
                return "Requires a property name to update"
        ADD_TO_GROUP, REMOVE_FROM_GROUP:
            if not _group:
                return "Requires a group name to update"
	return ""

func _get(p_property: String):
	pass

func _set(p_property: String, p_value):
	pass

func _get_property_list() -> Array:
	pass

##### VIRTUALS #####

##### PUBLIC METHODS #####

##### PRIVATE METHODS #####

##### SETTERS AND GETTERS #####

func get_effects():
	return _effects

func get_request():
	var req
	match type:
		NIL:
			pass
        ADD_PROPERTY, ASSIGN_PROPERTY, INVERT_PROPERTY:
            _calculate_value()
			req = GDSEffectServer.UpdatePropertyRequest.new(_node, _property, _value)
		ADD_TO_GROUP, REMOVE_FROM_GROUP:
			req = GDSEffectServer.UpdateGroupRequest.new(_node, _group, _persistent)
    return req

func _calculate_value():
    match type:
        ADD_PROPERTY:
            _calculate_add_value()

func _calculate_add_value():
    assert _node

    var original_value = _node.get(_property)
    var delta_type = typeof(_delta)

    var final_delta = null
    match delta_type:
        TYPE_INT:
            final_delta = int(_delta)
        TYPE_REAL:
            final_delta = float(_delta)
        TYPE_STRING, TYPE_NODE_PATH:
            final_delta = _delta
        _:
            printerr("GDSEffectServer: Delta-ing property of incompatible type. Must be stringy or numeric")
            assert false
    
    _value = original_value
    match _is_percentage:
        GDSAddPropertyRequest.PERCENT_NONE:
            _value += final_delta
        GDSAddPropertyRequest.PERCENT_RELATIVE:
            _value += final_delta * _value
        GDSAddPropertyRequest.PERCENT_ABSOLUTE:
            var multiplier = 1
            match delta_type:
                TYPE_INT:
                    multiplier = round(_max)
                TYPE_REAL:
                    multiplier = float(_max)
            _value += final_delta * multiplier

    if _is_clamped:
	    _value = clamp(new_value, float(_min), float(_max))
		if delta_type == TYPE_INT:
			_value = round(_value)

func _calculate_assign_value():
    pass

func _calculate_invert_value(p_node: Node, p_property: String, p_value):
    _value = p_node.get(p_property)

    match typeof(p_value):
        TYPE_INT, TYPE_REAL:
            _value = -_value
        TYPE_BOOL:
            _value = !_value
        _:
            printerr("GDSEffectServer: Inverting property of incompatible type. Must be boolean or numeric")
            assert false