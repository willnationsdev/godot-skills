# SkillSystem is meant to be an Autoload Singleton.
# It enables all references to Skills to automatically
# use their name rather than their full path to acquire
# their script or scene.
extends Node

# If a targeter has already visited and updated its static group, then targeter_is_stale[(targeter_script_path)] == false
# If the SkillSystem has been notified that the group has become stale, then it will be 'true'
var targeter_is_stale = []
var regex = RegEx.new()

func get_targets(p_targeter_script, p_targeter_func):
    var group = p_targeter_script.get_path()

    # If we already have a collective target that is up-to-date, return the targeted collection
    if not targeter_is_stale[group]:
        return get_nodes_in_group(group)

    # Update the group to have all of the targets (and no other nodes)
    var nodes = get_nodes_in_group(group)
    nodes = p_targeter_func.call_func()
    targeter_is_stale[group] = false
    return nodes

    # for node in get_nodes_in_group(group):
    #     if not node in targets:
    #         node.remove_from_group(group)
    # for target in targets:
    #     if not target.is_in_group(group):
    #         target.add_to_group(group)

func _enter_tree():
    var skill_json = File.new()
    skill_json.open("res://skills.json", File.WRITE)
    # defined at https://regex101.com/r/EQYwk1/1
    # Isolates files that have "Effect" or "Skill" at the end of the name
    # with a script or scene file extension
    regex.compile("/(?P<filename>(?P<title>\w*)(?P<type>(?:E|_e)ffect|(?:S|_s)kill|(?:T|_t)arteger))(?P<ext>(?P<script>\.gd|\.gdns|\.cs|\.vs)|(?P<scene>\.t?scn))\b)/")
    var files = {}
    _find_files("res://", files)
    skill_json.store_string(to_json(_find_files()))

static func _find_files(p_dir, p_files):
    var dir = Directory.new()
    if dir.open(p_dir) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while (file_name != ""):
            if dir.current_is_dir():
                _find_files(file_name, p_files)
            else:
                var regexMatch = regex.search(file_name)
                if regexMatch != null:
                    p_files[get_path() + "/" + file_name] = regexMatch.get_names()
            file_name = dir.get_next()
        dir.list_dir_end()