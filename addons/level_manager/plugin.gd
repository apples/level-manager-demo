@tool
extends EditorPlugin

const LEVELS_DOCK = preload("res://addons/level_manager/levels_dock.tscn")

var levels_dock: Node

func _enter_tree() -> void:
	add_autoload_singleton("LevelManager", "res://addons/level_manager/level_manager.gd")
	
	(func ():
		levels_dock = LEVELS_DOCK.instantiate()
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, levels_dock)
	).call_deferred()

func _exit_tree() -> void:
	remove_autoload_singleton("LevelManager")
	levels_dock.queue_free()
