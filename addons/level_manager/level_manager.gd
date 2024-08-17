@tool
extends Node

signal levels_refreshed()

const LEVELS_DIR = "res://levels"

## Maps level ids to level data, where level data is { id, dir, scene_file }.
var levels: Dictionary

func _enter_tree() -> void:
	refresh_levels()
	if Engine.is_editor_hint():
		Engine.get_singleton("EditorInterface").get_resource_filesystem().filesystem_changed.connect(refresh_levels)

func refresh_levels() -> void:
	levels = {}
	
	for level_id in DirAccess.get_directories_at(LEVELS_DIR):
		var level_dir := LEVELS_DIR.path_join(level_id)
		var level_scene_file := level_dir.path_join(level_id + ".tscn")
		
		if not FileAccess.file_exists(level_scene_file):
			push_warning("Level %s is missing its scene file!" % [level_dir])
			continue
		
		levels[level_id] = { id = level_id, dir = level_dir, scene_file = level_scene_file }
	
	levels_refreshed.emit()
