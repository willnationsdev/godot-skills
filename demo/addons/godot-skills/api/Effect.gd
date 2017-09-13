# Effects are the Node-ification of the Functor concept, i.e. a function as an object.
# Effects "apply" an effect, potentially using member variables set in advance as context.
# Effects can be attached underneath Skill nodes for compositional construction of algorithms
# in a Scene.
extends "SkillDescendant.gd"

# private
var _child_effects = []
var _apply = FuncRef()
var _revert = FuncRef()

func _enter_tree():
    _skill_cache_list = "effects"

func _ready():
    for child in get_children():
        if child extends "Effect.gd":
            _child_effects[] = child
    _apply.set_instance(self)
    _revert.set_instance(self)

# Applies some effect to the target, possibly using information 
# provided by p_source and possibly using member variables of
# the Effect instance.
# Note, this method will be completely replaced in derived implementations
# DO NOT REPLACE
func apply(p_source, p_target):
    for child in _child_effects:
        child.apply(p_source, p_target)
    _apply.call_func(p_source, p_target)

# Negates the effect of "apply" on the target. May involve the need
# to store helper variables pertinent to properly restoring the properties
# of the target
#
# One should only call this method on the target during test evaluations.
#
# Note, this method will be completely replaced in derived implementations
# DO NOT REPLACE
func revert(p_source, p_target):
    _revert.call_func(p_source, p_target)
    for child in _child_effects:
        child.revert(p_source, p_target)