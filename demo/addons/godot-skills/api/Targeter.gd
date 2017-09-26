# Targeters are responsible for locating SkillUsers that meet given criteria.
# They may update manually with every request for targets or automatically 
#     as SkillUsers are added or removed from the tree.
# All depends on the criteria sought after and what the most efficient algorithm
#     is for locating nodes based on that criteria.
extends "SkillDescendant.gd"

##### SIGNALS #####
signal target_found(p_targeter, p_target)

##### CONSTANTS #####
const Util = preload("GodotSkillUtilities.gd")

##### EXPORTS #####

##### MEMBERS #####
var skill = null            # The Skill or Targeter that owns this Targeter
var targeters = []          # cached list of descendant Targeter nodes
var _child_targeters = []   # Targeter children cache
var _targets = []           # The set of targets for this Targeter. Only used if `static` is false

##### NOTIFICATIONS #####

# Initializes child Targeter cache
func _ready():
    for child in get_children():
        if child extends "Targeter.gd":
            _child_targeters[] = child

# Custom Notification
# null base implementation, to be overridden
# Acquires targets for this Targeter
func _target():
    pass

##### METHODS #####

# Acquires the targets for this Targeter and its children
func get_targets():
    var r_targets = {} # Assures we'll have a unique list

    for child in _child_targeters:
        for target in child.get_targets():
            r_targets[target] = null

    for target in _target():
        r_targets[target] = null
        emit_signal("target_found", self, target)
        Util.get_skill_system().emit_signal("target_found", self, target)

    return r_targets.keys()

##### SETTERS AND GETTERS  #####