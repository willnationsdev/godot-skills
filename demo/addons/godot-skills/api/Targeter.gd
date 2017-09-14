# Targeters are responsible for locating SkillUsers that meet given criteria.
# They may update manually with every request for targets or automatically 
#     as SkillUsers are added or removed from the tree.
# All depends on the criteria sought after and what the most efficient algorithm
#     is for locating nodes based on that criteria.
extends "SkillDescendant.gd"

# public

# @return If true, targets are processed script-wide in the SkillSystem
func is_static():
    return static

# Acquires the targets for this Targeter and its children
# @return Array
func get_targets():
    var r_targets = {} # Assures we'll have a unique list
    for child in _child_targeters:
        for target in child.get_targets():
            r_targets[target] = null
    if static:
        get_node(get_skill_system_path()).get_targets(get_script(), _get_targets_func)
        for target in get_nodes_in_group(get_script().get_path()):
            r_targets[target] = null
    else:
        for target in _get_targets_func.call_func():
            r_targets[target] = null
    return r_targets.keys()

static func get_skill_system_path():
    return "/skill_system"

# protected (technically also public)

# Acquires the targets for this Targeter
# @return void
func _enter_tree():
    _skill_cache_list = "targeters"
    _get_targets_func.set_instance(self)
    _bind()

    # Update the Skill System to let it know that we need to update this script's targets
    if static:
        get_node(get_skill_system_path()).targeter_is_stale[get_script().get_path()] = true

# Initializes child Targeter cache
func _ready():
    for child in get_children():
        if child extends "Targeter.gd":
            _child_targeters[] = child

# Helper function for derived Targeters to easily get set up.
func _bind(p_target_name = "_target"):
    _get_targets_func.set_function(p_target_name)

# null base implementation
func _target():
    pass

# If true, SkillSystem processes get_targets and stores results for all Targeters of this type.
# If false, each individual Targeter of this type finds its own targets
var static = false setget , is_static

# private (technically also protected)

var _child_targeters = [] setget ,          # Targeter children cache
var _get_targets_func = FuncRef() setget ,  # Gathers targets for this Targeter.
var _targets = [] setget ,                  # The set of targets for this Targeter. Only used if `static` is false
