@tool
extends MarginContainer

enum {
	BUTTON_EDIT_SCENE = 1,
}

const LevelManager = preload("res://addons/level_manager/level_manager.gd")

var level_manager: LevelManager

var root_item: TreeItem

@onready var tree: Tree = %Tree
@onready var create_button: Button = %CreateButton

@onready var create_level_dialog: ConfirmationDialog = %CreateLevelDialog
@onready var name_label: Label = %NameLabel
@onready var name_edit: LineEdit = %NameEdit
@onready var path_label: Label = %PathLabel
@onready var path_edit: LineEdit = %PathEdit
@onready var error_label: Label = %ErrorLabel

func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	
	level_manager = $/root/LevelManager
	assert(level_manager)
	
	root_item = tree.create_item()
	
	refresh()
	level_manager.levels_refreshed.connect(refresh)
	
	create_button.icon = get_theme_icon("Add", "EditorIcons")
	error_label.add_theme_color_override("font_color", get_theme_color("error_color", "Editor"))

func refresh() -> void:
	var levels := level_manager.levels.values()
	
	for i in levels.size():
		var level_item: TreeItem
		
		if root_item.get_child_count() <= i:
			level_item = root_item.create_child()
			level_item.set_icon(0, get_theme_icon("Environment", "EditorIcons"))
			level_item.add_button(0, get_theme_icon("InstanceOptions", "EditorIcons"),
				BUTTON_EDIT_SCENE, false, "Edit Scene")
		else:
			level_item = root_item.get_child(i)
		
		level_item.set_metadata(0, levels[i].id)
		level_item.set_text(0, levels[i].id.to_pascal_case())
	
	for i in range(root_item.get_child_count() - 1, levels.size() - 1, -1):
		root_item.get_child(i).free()

func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	
	match id:
		BUTTON_EDIT_SCENE:
			var level_id = item.get_metadata(column)
			var level = level_manager.levels[level_id]
			EditorInterface.open_scene_from_path(level.scene_file)

func _on_create_button_pressed() -> void:
	create_level_dialog.popup_centered()
	_update_create_level_dialog()

func _on_name_edit_text_changed(_new_text: String) -> void:
	_update_create_level_dialog()

func _update_create_level_dialog() -> void:
	var level_id := name_edit.text.to_snake_case()
	var level_dir := level_manager.LEVELS_DIR.path_join(level_id)
	var level_scene_file := level_dir.path_join(level_id + ".tscn")
	
	path_edit.text = level_scene_file
	
	if level_id == "":
		error_label.text = "Name is required!"
	elif not level_id.is_valid_filename():
		error_label.text = "Level name is not valid!"
	elif FileAccess.file_exists(level_scene_file):
		error_label.text = "Level already exists!"
	elif DirAccess.dir_exists_absolute(level_dir):
		error_label.text = "A non-level directory already exists."
	else:
		error_label.text = ""
	
	create_level_dialog.get_ok_button().disabled = error_label.text != ""

func _on_create_level_dialog_confirmed() -> void:
	var level_id := name_edit.text.to_snake_case()
	var level_dir := level_manager.LEVELS_DIR.path_join(level_id)
	var level_scene_file := level_dir.path_join(level_id + ".tscn")
	
	DirAccess.make_dir_recursive_absolute(level_dir)
	
	var level_node := preload("res://node_types/level.gd").new()
	level_node.name = name_edit.text
	level_node.queue_free()
	
	var background := Sprite2D.new()
	background.name = "Background"
	background.texture = preload("res://backgrounds/clouds.png")
	background.position = Vector2(160, 120)
	level_node.add_child(background)
	background.owner = level_node
	
	var tilemap := TileMapLayer.new()
	tilemap.name = "TileMapLayer"
	tilemap.tile_set = preload("res://tilesets/tiles_tileset.tres")
	level_node.add_child(tilemap)
	tilemap.owner = level_node
	
	var err: Error
	
	var scene := PackedScene.new()
	
	err = scene.pack(level_node)
	if err != OK:
		push_error("Failed to pack level:", error_string(err))
		return
	
	scene.resource_path = level_scene_file
	
	err = ResourceSaver.save(scene)
	if err != OK:
		push_error("Failed to save level:", error_string(err))
		return
	
	EditorInterface.get_resource_filesystem().scan()
