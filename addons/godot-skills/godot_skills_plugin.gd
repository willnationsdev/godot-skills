tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Effect", "Node", preload("api/effect.gd"), preload("api/icons/icon_effect.png"))
	add_custom_type("Targeter", "Node", preload("api/targeter.gd"), preload("api/icons/icon_targeter.png"))
	add_custom_type("Skill", "Node", preload("api/skill.gd"), preload("api/icons/icon_skill.png"))
	add_custom_type("Filter", "Node", preload("api/filter.gd"), preload("api/icons/icon_filter.png"))
	add_custom_type("Condition", "Node", preload("api/condition.gd"), preload("api/icons/icon_condition.png"))
	add_custom_type("SkillUser", "Node", preload("api/skill_user.gd"), preload("api/icons/icon_skill_user.png"))

func _exit_tree():
	remove_custom_type("SkillUser")
	remove_custom_type("Condition")
	remove_custom_type("Filter")
	remove_custom_type("Skill")
	remove_custom_type("Targeter")
	remove_custom_type("Effect")
