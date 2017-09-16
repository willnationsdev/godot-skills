tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Effect", "Node", preload("api/Effect.gd"), preload("api/icons/icon_effect.png"))
	add_custom_type("Targeter", "Node", preload("api/Targeter.gd"), preload("api/icons/icon_targeter.png"))
	add_custom_type("SkillSystem", "Node", preload("api/SkillSystem.gd"), preload("api/icons/icon_skill_system.png"))
	add_custom_type("Skill", "Node", preload("api/Skill.gd"), preload("api/icons/icon_skill.png"))
	add_custom_type("SkillDescendant", "Node", preload("api/SkillDescendant.gd"), preload("api/icons/icon_skill_descendant.png"))
	add_custom_type("SkillUser", "Node", preload("api/SkillUser.gd"), preload("api/icons/icon_skill_user.png"))

func _exit_tree():
	remove_custom_type("SkillUser")
	remove_custom_type("SkillDescendant")
	remove_custom_type("Skill")
	remove_custom_type("SkillSystem")
	remove_custom_type("Targeter")
	remove_custom_type("Effect")
