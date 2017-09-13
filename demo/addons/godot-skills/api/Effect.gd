# Effects are the Node-ification of the Functor concept, i.e. a function as an object.
# Effects "apply" an effect, potentially using member variables set in advance as context.
# Effects can be attached underneath Skill nodes for compositional construction of algorithms
# in a Scene.
extends "SkillDescendant.gd"

func _enter_tree():
    _skill_cache_list = "effects"

# Applies some effect to the target, possibly using information 
# provided by p_source and possibly using member variables of
# the Effect instance.
# Note, this method will be completely replaced in derived implementations
func apply(p_source, p_target):
    pass

# Negates the effect of "apply" on the target. May involve the need
# to store helper variables pertinent to properly restoring the properties
# of the target
#
# One should only call this method on the target during test evaluations.
#
# Note, this method will be completely replaced in derived implementations
func revert(p_source, p_target):
    pass