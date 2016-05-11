
extends Node

const PLAYER_SCENE = preload("res://scenes/player.xscn")

# For tracking the player/room
var player
var room

# Current scene, including e.g. the main menu
var current_scene

# World variables
var items = {}
var factions = {}

# Global game variables
var dead_npcs = []

# Functions for selecting from global variables
func select_item(id):
	return items[id]

func select_faction(id):
	return factions[id]

func npc_died(id):
	if not (id in dead_npcs): # Do not add repeats
		dead_npcs.append(id)

func new_game():
	call_deferred("_deferred_new_game")

func _deferred_new_game():
	player = PLAYER_SCENE.instance()
	player.id = "player"
	player.is_player = true
	dead_npcs = []
	current_scene.free()
	var s = ResourceLoader.load("res://scenes/quizixville.xscn")
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )
	room = current_scene.get_node("room")
	player.x = 8
	player.y = 8
	player.armor_id = "old_plate"
	player.species = "nathulan"
	room.add_child(player)
	room.redraw(player)

func load_game(name):
	player = PLAYER_SCENE.instance()
	player.id = "player"
	var x = ConfigFile.new()
	x.load("user://saves/" + name + ".save.cfg")
	player.stat_str = x.get_value("Player", "strength")
	player.stat_spd = x.get_value("Player", "speed")
	player.stat_int = x.get_value("Player", "intelligence")
	player.stat_acc = x.get_value("Player", "accuracy")

func change_rooms(path, x, y):
	call_deferred("_deferred_change_rooms", path, x, y)

func _deferred_change_rooms(new_room, x, y):
	room.remove_child_player()
	current_scene.free()
	var s = ResourceLoader.load(new_room)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )
	room = current_scene.get_node("room")
	player.x = x
	player.y = y
	room.add_child(player)
	room.redraw(player)

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )

func read_json_file(loc):
	var f = File.new()
	f.open(loc, File.READ)
	var d = {}
	d.parse_json(f.get_as_text())
	f.close()
	return d

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	
	# Initialize global data
	items = read_json_file("res://data/items.json")
	factions = read_json_file("res://data/faction.json")
