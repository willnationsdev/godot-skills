extends Reference

const Targeter = preload("Targeter.gd")

static func fetch_skill_user(p_node):
	var parent = p_node.get_parent()
	while parent and not parent is preload("SkillUser.gd"):
		parent = parent.get_parent()
	return parent

static func fetch_skill(p_node):
	var parent = p_node.get_parent()
	while parent and not parent is preload("Skill.gd"):
		parent = parent.get_parent()
	return parent

# This is probably really slow, so need to figure out a more efficient way.
# This updates all copied Targeter nodes' "targeter_id" property so that
# they fetch the same record of targets from the TargetingSystem singleton.
# May try re-implementing using yielded signals to ping requested targets back and forth.
static func init_test_skill(p_test_skill, p_original_skill):
	p_test_skill._targeting_system_id = p_original_skill._targeting_system_id