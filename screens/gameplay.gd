extends Node2D

@export var first_level: String

var current_level: Node2D

@onready var player_character: CharacterBody2D = $PlayerCharacter

func _ready() -> void:
	current_level = load("res://levels/{name}/{name}.tscn".format({ name = first_level })).instantiate()
	add_child(current_level)
	move_child(current_level, 0)

func _process(_delta: float) -> void:
	if player_character.position.x > 320:
		if current_level.next_level_right:
			_level_transition(current_level.next_level_right, 1.0)
		else:
			player_character.position.x = 320
	elif player_character.position.x < 0:
		if current_level.next_level_left:
			_level_transition(current_level.next_level_left, -1.0)
		else:
			player_character.position.x = 0


func _level_transition(level_name: String, dir: float) -> void:
	get_tree().paused = true
	var next_level: Node2D = load("res://levels/{name}/{name}.tscn".format({ name = level_name })).instantiate()
	next_level.position.x = 320.0 * dir
	add_child(next_level)
	move_child(next_level, 0)
	var tween_time = 1.0
	var tween = create_tween().set_parallel().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(current_level, "position:x", -320.0 * dir, tween_time)
	tween.tween_property(next_level, "position:x", 0.0, tween_time)
	tween.tween_property(player_character, "position:x", player_character.position.x - 320.0 * dir, tween_time)
	await tween.finished
	current_level.queue_free()
	current_level = next_level
	get_tree().paused = false

