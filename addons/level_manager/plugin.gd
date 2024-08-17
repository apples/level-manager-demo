@tool
extends EditorPlugin

signal levels_refreshed()

const LEVELS_DIR = "res://levels"

const LEVELS_DOCK = preload("res://addons/level_manager/levels_dock.tscn")

## Maps level ids to level data, where level data is { id, dir, scene_file }.
var levels: Dictionary

var levels_dock: Node

func _enter_tree() -> void:
	refresh_levels()
	get_editor_interface().get_resource_filesystem().filesystem_changed.connect(refresh_levels)
	
	levels_dock = LEVELS_DOCK.instantiate()
	levels_dock.plugin = self
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, levels_dock)

func _exit_tree() -> void:
	levels_dock.queue_free()

func refresh_levels() -> void:
	levels = {}
	
	for level_id in DirAccess.get_directories_at(LEVELS_DIR):
		var level_dir := LEVELS_DIR.path_join(level_id)
		var level_scene_file := level_dir.path_join(level_id + ".tscn")
		
		if not ResourceLoader.exists(level_scene_file):
			push_warning("Level %s is missing its scene file!" % [level_dir])
			continue
		
		levels[level_id] = { id = level_id, dir = level_dir, scene_file = level_scene_file }
	
	levels_refreshed.emit()
