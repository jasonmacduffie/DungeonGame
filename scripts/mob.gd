
extends Node2D

const FAR_AWAY = 10000
const ROAM = 0
const SEARCH = 1
const FLEE = 2

# basic stats
export(int, 0, 10) var stat_str = 4
export(int, 0, 10) var stat_spd = 4
export(int, 0, 10) var stat_int = 4
export(int, 0, 10) var stat_acc = 4

# derived stats
var max_hp
var attack_power

var hp_damage = 0
var x = 0
var y = 0
var dead = false
export(int, "roam", "search", "flee") var movement = 0
var walkable = ["walkable"]
var facing = "down"

export var name = ""
export var species = "creature" # This is a string, to be flexible

# A custom skin may be specified
export var sprite_resource = ""

# Armor is just one piece to make things simpler
export var armor_id = "none"
var armor

export var weapon_id = "none"
var weapon

# negative is enemy
# 0 to 50 is neutral
# 50 to 100 is friendly
export(int, -100, 100) var disposition = 50

# conversation topics are in JSON-like format
var conversations = {
	"initial" : "Hello there, character.",
	"options" : [
		{
			"description" : "Small Talk",
			"initial" : "The weather is terrible.",
			"options" : []
		}
	]
}

# Allow loading external conversation trees
export var external_conv = false
export var conv_resource = ""

func face(direction):
	facing = direction
	var sprites = [get_node("sprite"), get_node("armor_sprite"), get_node("weapon_sprite")]
	if direction == "down":
		for i in sprites:
			i.set_frame(0)
	elif direction == "right":
		for i in sprites:
			i.set_frame(1)
	elif direction == "up":
		for i in sprites:
			i.set_frame(2)
	else:
		for i in sprites:
			i.set_frame(3)

func can_walk(tile_type):
	return tile_type in walkable

func move(direction):
	assert(direction in ["up", "down", "left", "right"])
	if direction == "up":
		y -= 1
	elif direction == "down":
		y += 1
	elif direction == "right":
		x += 1
	else:
		x -= 1
	
	face(direction)

func equip_armor(id):
	armor = get_node("/root/game").select_armor(id)
	if armor['texture'] == null:
		get_node("armor_sprite").set_texture(null)
	else:
		get_node("armor_sprite").set_texture(load(armor['texture']))

func equip_weapon(id):
	weapon = get_node("/root/game").select_weapon(id)
	if weapon['texture'] == null:
		get_node("weapon_sprite").set_texture(null)
	else:
		get_node("weapon_sprite").set_texture(load(weapon['texture']))

func die():
	dead = true
	x = -FAR_AWAY
	y = -FAR_AWAY
	get_node("/root/game").room.redraw(self)

func damage(dmg):
	hp_damage += dmg
	if hp_damage > max_hp:
		die()

func attack(mob):
	mob.damage(attack_power)

func load_sprite(loc):
	get_node("sprite").set_texture(load(loc))

func _ready():
	max_hp = 8 * stat_str
	attack_power = 1 * stat_str
	# Load an external sprite if not null
	if sprite_resource != "":
		load_sprite(sprite_resource)
	# You can also load a generic species sprite
	elif species in ["human", "roandan", "dokoran", "hermadon", "nathulan", "treddan"]:
		load_sprite("res://images/" + species + ".png")
	# Load an external conversation if specified
	if external_conv:
		var f = File.new()
		f.open(conv_resource, File.READ)
		var s = f.get_as_text()
		var conv = {}
		conv.parse_json(s)
		conversations = conv
		f.close()
	
	# Equip initial armor and weapon
	equip_weapon(weapon_id)
	equip_armor(armor_id)
