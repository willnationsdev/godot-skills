# SkillDescendants look for the closest Skill in the hierarchy above them
# and add themselves to its corresponding cache.
# This allows for Skill-informing nodes to automatically become accessible
# without the Skill having to manually search for related nodes periodically.
extends Node

# Which property on the ancestor Skill are we adding this node to?
var _skill_cache_list = ""
# cached skill reference
var skill = null

func _enter_tree():
    var node = self

    # Search for a Skill node above us in the hierarchy
    while not node extends "Skill.gd" or get_parent() == null:
        node = get_parent()

    # If we find an ancestor Skill, add this Targeter to its cache to accommodate dynamic attachment.
    if node extends "Skill.gd":
        node.get(_skill_cache_list) [] = self

func _exit_tree():
    # Remove this Targeter from the ancestor Skill to accommodate dynamic removal.
    if skill != null:
        skill.get(_skill_cache_list).erase(self)