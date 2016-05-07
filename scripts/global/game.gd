
extends Node

const PLAYER_SCENE = preload("res://scenes/player.xscn")
var player
var room
var current_scene

func goto_scene(path):
	pass
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )

	# Remove this in the future to make more rooms possible
	player = PLAYER_SCENE.instance()
	room = current_scene
	room.add_child(player)

