extends Control

export(String, MULTILINE) var file_regex = "" setget set_file_regex, get_file_regex

func set_file_regex(p_regex): file_regex = p_regex
func get_file_regex():        return file_regex