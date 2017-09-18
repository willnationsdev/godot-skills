# Effects are the Node-ification of the Functor concept, i.e. a function as an object.
# Effects "apply" an effect, potentially using member variables set in advance as context.
# Effects can be attached underneath Skill nodes for compositional construction of algorithms
# in a Scene.
extends "SkillDescendant.gd"

# public 

# Applies all child effects on the target and then its own effect.
# DO NOT REPLACE
func apply(p_source, p_target):
    for child in _child_effects:
        child.apply(p_source, p_target)
    _apply_func.call_func(p_source, p_target)

# Reverts its effect on the target and then reverts all child effects.
# DO NOT REPLACE
func revert(p_source, p_target):
    _revert_func.call_func(p_source, p_target)
    for child in _child_effects:
        child.revert(p_source, p_target)

# protected (technically also public)

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

# null base implementation
func _apply(p_source, p_target):
    pass

# null base implementation
func _revert(p_source, p_target):
    pass

# private (technically also protected)

var _child_effects = [] setget ,        # Effect children cache
var _apply_func = FuncRef() setget ,    # Applies some effect to the target.
var _revert_func = FuncRef() setget ,   # Negates the effect of "apply" on the target. Only test evaluations should use this method.
