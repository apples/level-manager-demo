@tool
extends Node2D

@export var next_level_left: String = ""
@export var next_level_right: String = ""

func _enter_tree() -> void:
	LevelManager.levels_refreshed.connect(notify_property_list_changed)

func _exit_tree() -> void:
	LevelManager.levels_refreshed.disconnect(notify_property_list_changed)

func _validate_property(property: Dictionary) -> void:
	if property.name in ["next_level_left", "next_level_right"]:
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(LevelManager.levels.keys())
