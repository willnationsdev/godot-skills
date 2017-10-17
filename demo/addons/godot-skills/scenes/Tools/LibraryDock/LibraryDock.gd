extends Control

const Skills = preload("../../../api/GodotSkillsUtility.gd")

var skill_scene_regex = RegEx.new()
var regex_dict = {}
var update_button = null
var library_tabs = null

func _init():
	skill_scene_regex.compile("(?P<title>\\w*)(?:_s|S)kill\\.t?scn")

func _ready():
	update_button = get_node("main_container/content/toolbar/update_button")
	update_button.connect("pressed", self, update)
	library_tabs = get_node("main_container/content/library/tabs")
	for tab in library_tabs.get_children():
		var regex = RegEx.new()
		if tab.has_method("get_file_regex"):
			regex.compile(tab.get_file_regex())
		regex_dict[tab.get_name()] = regex

# Find all scene files with "skill" at the end of their name and map their names to their scene filepaths, example:
# "fire_wall"	: res://fire_wall_skill.tscn
# "fireWall"  	: res://dir/fireWallSkill.scn
func update():
	var path_to_title_map = Skills.search_res(regex_dict[library_tabs.get_current_tab_control().get_name()])