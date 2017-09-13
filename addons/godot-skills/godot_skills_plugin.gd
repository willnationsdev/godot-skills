tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Effect", "Node", preload("/api/Effect.gd"), preload("api/icon_effect.png"))

func _exit_tree():
	remove_custom_type("Effect")
