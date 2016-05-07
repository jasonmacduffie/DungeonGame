
extends Node

const PLAYER_SCENE = preload("res://scenes/player.xscn")
var player
var room
var current_scene

func load_game(name):
	player = PLAYER_SCENE.instance()
	var x = ConfigFile.new()
	x.load("user://saves/" + name + ".save.cfg")
	player.stat_str = x.get_value("Player", "strength")
	player.stat_spd = x.get_value("Player", "speed")
	player.stat_int = x.get_value("Player", "intelligence")
	player.stat_acc = x.get_value("Player", "accuracy")

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
	load_game("default")
	room = current_scene
	room.add_child(player)
	player.x = 1
	player.y = 1
	room.redraw(player)

