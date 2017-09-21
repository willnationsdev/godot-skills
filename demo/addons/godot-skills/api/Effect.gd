# Effects are the Node-ification of the Functor concept, i.e. a function as an object.
# Effects "apply" an effect, potentially using member variables set in advance as context.
# Effects can be attached underneath Skill nodes for compositional construction of algorithms
# in a Scene. They can also be attached underneath other Effects, in which case they are
# executed prior to that Effect.
# 
# Examples of an Effect may include...
# DamageEffect:         Subtracts an "amount" from a property on the target. The default property name is "health".
#                       Has boolean "percentage": if true, "amount" is multiplied against the property and then subtracted (100 subtracts all).
# RestoreEffect:        Adds an "amount" to a property on the target, but not more than some maximum value. The 
#                       default value for the property and max property are "health" and "max_health", respectively.
#                       Has boolean "percentage": if true, "amount" is multiplied against the max property and then added (100 restores all).
# 
# 
# 
extends Node

# public 

signal effect_applied(p_effect, p_source, p_target)

var ancestor = null setget , get_ancestor       # The Skill or Effect that owns this Effect, required
var effects = [] setget , get_effects           # cached list of descendant Effect nodes

# Applies all child effects on the target and then its own effect.
# DO NOT REPLACE
func apply(p_source, p_target):
    for child in _child_effects:
        child.apply(p_source, p_target)
    _apply_func.call_func(p_source, p_target)
    if not _testing:
        emit_signal("effect_applied", self, p_source, p_target)

# Reverts its effect on the target and then reverts all child effects.
# DO NOT REPLACE
func revert(p_source, p_target):
    _revert_func.call_func(p_source, p_target)
    for child in _child_effects:
        child.revert(p_source, p_target)
    if _testing:
        _testing = false

# protected

# Initializes parent skill cache storage and function references for derived scripts.
func _init():
    _skill_cache_list = "effects"
    _apply_func.set_instance(self)
    _revert_func.set_instance(self)
    _bind()

# Initializes child Effect cache and function references for derived scripts.
func _ready():
    for child in get_children():
        if child extends "Effect.gd":
            _child_effects[] = child

# Helper function for derived Effects to easily get set up.
func _bind(p_apply_name = "_apply", p_revert_name = "_revert"):
    _apply_func.set_function(p_apply_name)
    _revert_func.set_function(p_revert_name)

# null base implementation, to be overridden
func _apply(p_source, p_target):
    pass

# null base implementation, to be overridden
func _revert(p_source, p_target):
    pass

func get_skill():
    var node = self
    while not node extends "Skill.gd":
        node = node.ancestor
    return node

# private

var _child_effects = []         # Effect children cache
var _apply_func = FuncRef()     # Applies some effect to the target.
var _revert_func = FuncRef()    # Negates the effect of "apply" on the target. Only test evaluations should use this method.
var _testing = false            # If true, the current application of the Effect is meant for testing. Be prepared to revert and don't emit signals