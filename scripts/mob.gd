
extends Node2D

const FAR_AWAY = 10000
const ROAM = 0
const SEARCH = 1
const FLEE = 2

# a unique id, for keeping track of npc death
export var id = "respawnable"

# just describes whether the mob is the player
var is_player = false

# basic stats
export(int, 0, 10) var stat_str = 4
export(int, 0, 10) var stat_spd = 4
export(int, 0, 10) var stat_int = 4
export(int, 0, 10) var stat_acc = 4

# derived stats
var max_hp
var attack_power
var attack_range = 1
var vision_range = 5

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
export var armor_id = "noarmor"
var armor
export var melee_weapon_id = "nomeleeweapon"
var melee_weapon
export var ranged_weapon_id = "norangedweapon"
var ranged_weapon

export(StringArray) var factions = []
var aggressive = false
var friends = []
var enemies = []

var inventory = []

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

func mob_distance(mob):
	# Get the orthogonal distance between self and mob
	return abs(mob.x - x) + abs(mob.y - y)

func in_attack_range(mob):
	# Determine whether the target is in attack range
	return mob_distance(mob) <= min(attack_range, vision_range)

func in_vision_range(mob):
	# Determine whether the target is in vision range,
	# and the direction to face if so
	return mob_distance(mob) <= vision_range

func direction_towards(mob):
	# Determine the correct direction to face this mob
	var rightness
	var downness
	if mob.x - x < 0:
		rightness = "left"
	else:
		rightness = "right"
	if mob.y - y < 0:
		downness = "up"
	else:
		downness = "down"
	if abs(mob.x - x) < abs(mob.y - y):
		return [downness, rightness]
	else:
		return [rightness, downness]

func mob_take_turn(mob):
	var mobloc = Vector2(mob.x, mob.y)
	# Check whether the mob can attack
	for i in get_mobs():
		if mob != i and mob_distance(mob, i) <= min(mob.vision_range, mob.attack_range) and mob.is_enemy(i):
			mob.attack(i)
			return

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
	armor = get_node("/root/game").select_item(id)
	if armor['texture'] == null:
		get_node("armor_sprite").set_texture(null)
	else:
		get_node("armor_sprite").set_texture(load(armor['texture']))

func equip_weapon(id):
	melee_weapon = get_node("/root/game").select_item(id)
	if melee_weapon['texture'] == null:
		get_node("weapon_sprite").set_texture(null)
	else:
		get_node("weapon_sprite").set_texture(load(melee_weapon['texture']))

func start_dead():
	# Make the npc dead without checking the global variable
	dead = true
	x = -FAR_AWAY
	y = -FAR_AWAY

func die():
	dead = true
	x = -FAR_AWAY
	y = -FAR_AWAY
	get_node("/root/game").room.redraw(self)
	
	if id != "respawnable":
		get_node("/root/game").npc_died(id)
	
	if not is_player:
		queue_free()

func damage(dmg):
	# Modify dmg by armor value
	var actual_damage = dmg * (1 - armor['protection']/100.0)
	hp_damage += actual_damage
	if hp_damage > max_hp:
		die()

func melee_attack(mob):
	mob.damage(attack_power + melee_weapon['damage'])

func load_sprite(loc):
	get_node("sprite").set_texture(load(loc))

func is_enemy(mob):
	# Determine whether hostile to this character
	if mob.is_player:
		# High disposition overloads faction relations
		if disposition > 90:
			return false
		# Same for low disposition
		elif disposition < 0:
			return true
		# Otherwise treat like any other mob
		else:
			if aggressive:
				for i in mob.factions:
					if i in friends:
						return false
				return true
			for i in mob.factions:
				if i in enemies:
					return true
			return false
	# Aggressive mobs invert the test
	if mob.aggressive:
		for i in factions:
			if i in mob.friends:
				return false
		return true
	if aggressive:
		for i in mob.factions:
			if i in friends:
				return false
		return true
	# Check whether the target is in this mob's enemies
	for i in mob.factions:
		if i in enemies:
			return true
	# Check whether this mob is in the target mob's enemies
	for i in factions:
		if i in mob.enemies:
			return true
	return false

func reload_factions():
	# Load friends, enemies, and aggression
	friends = []
	enemies = []
	for i in factions:
		var f = get_node("/root/game").select_faction(i)
		if f.has('aggressive') and f['aggressive']:
			aggressive = true
		if f.has('friends'):
			for j in f['friends']:
				if not j in friends:
					friends.append(j)
		if f.has('enemies'):
			for j in f['enemies']:
				if not j in enemies:
					enemies.append(j)

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
	
	reload_factions()
	
	# Equip initial armor and weapon
	equip_weapon(melee_weapon_id)
	equip_armor(armor_id)
