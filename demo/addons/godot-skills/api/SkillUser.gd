# SkillUsers are responsible for managing Skills and their interaction with other nodes.
# SkillUsers provide the following functionality:
# - utilities for controlling Skill ownership and availability
# - filtration of incoming and outgoing Skills
# - managing skill conditions that are associated with the SkillUser
extends Node

##### CLASSES #####

class SkillFilter:
    extends Reference

    var mods = {} # FuncRef == (bool)(*)(Skill) : FuncRef == (void)(*)(Skill). If key(skill): value(skill)

    func filter(p_skill):
        if not p_skill is preload("Skill.gd"): return
        var skill = p_skill.duplicate(true)
        for criteria in mods:
            if criteria.call_func(skill):
                mods[criteria].call_func(skill)
        return skill

##### SIGNALS #####

##### CONSTANTS #####
const SkillCondition = preload("SkillCondition.gd")

##### EXPORTS #####

##### MEMBERS #####
var conditions = {} # condition_reference : number_of_instances
var outputFilter = SkillFilter.new()
var inputFilter = SkillFilter.new()

##### NOTIFICATIONS #####

##### METHODS #####

# @param The node of the skill to use. Typically use($skill_name)
func use(p_skill, p_params):
    var skill = outputFilter.filter(p_skill)
    skill.activate(self, p_params)

func accept(p_skill, p_params):
    var skill = inputFilter.filter(p_skill)
    p_params["target"] = self
    skill.apply(skill.get_owner(), p_params)

##### SETTERS AND GETTERS #####