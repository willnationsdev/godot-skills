extends "SignalUpdater.gd"

##### SIGNALS #####
signal skill_filtered(p_filter, p_skill)

##### CONSTANTS #####
enum { FILTER_INPUT, FILTER_OUTPUT }	# Whether the Filter should check incoming or outgoing Skills
const Effect = preload("Effect.gd")

##### EXPORTS #####
export(int, "Input", "Output") var filter_set = FILTER_INPUT

##### MEMBERS #####

##### NOTIFICATIONS #####

func _init():
	is_signal_target = false
	signals_to_update = get_signal_list()

##### VIRTUALS #####

# Determines whether the given skill should be modified
# @param p_skill_user SkillUser	The original user of the skill
# @param p_skill Skill 			The skill that will be examined and possibly modified
# @return bool 					If true, the filtered skill should be modified
func _filter(p_skill_user, p_skill):
	return true

##### METHODS #####

func filter(p_skill_user, p_skill):
	if _filter(p_skill_user, p_skill):
		for a_child in get_children():
			if a_child is Effect:
				a_child.apply(signal_target, p_skill, p_skill, {})
	for a_child in get_children():
		if a_child is get_script():
			a_child.filter(p_skill_user, p_skill)

##### SETTERS AND GETTERS #####