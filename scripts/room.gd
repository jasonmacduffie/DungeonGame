
extends Node2D

const MOB_CLASS = preload("res://scripts/mob.gd")
const TRANSITION_CLASS = preload("res://scripts/transition.gd")
const CONVERSATION_SCENE = preload("res://scenes/conversation.xscn")
const TILE_SIZE = 64
const TILE_TYPES = \
{
	-1: "impossible",
	 0: "impossible", # Nothing can pass
	 1: "walkable" # Anything can pass
}
# Other tile types
# solid, water, lava

var player
var direction_press = false

func _input(event):
	var valid = event.is_pressed() && !event.is_echo()
	if valid:
		if event.is_action("ui_left"):
			direction_press = "left"
		elif event.is_action("ui_right"):
			direction_press = "right"
		elif event.is_action("ui_up"):
			direction_press = "up"
		elif event.is_action("ui_down"):
			direction_press = "down"

func redraw(item):
	# This method displays the item in the correct coordinate
	var x = item.x
	var y = item.y
	item.set_pos(Vector2((x + 0.5) * TILE_SIZE, (y + 0.5) * TILE_SIZE))

func open_conversation(mob):
	var conv = CONVERSATION_SCENE.instance()
	conv.conversation_tree = mob.conversations
	get_node("canvas").add_child(conv)
	get_tree().set_pause(true)

func check_tile(mob, direction):
	var x = mob.x
	var y = mob.y
	if direction == "up":
		y -= 1
	elif direction == "down":
		y += 1
	elif direction == "right":
		x += 1
	else:
		x -= 1
	
	var tile_result = mob.can_walk(TILE_TYPES[get_node("tiles").get_cell(x,y)])
	var mob_result = false
	
	for i in get_children():
		if i extends MOB_CLASS and i.x == x and i.y == y:
				mob_result = i
				break
	
	if tile_result:
		if mob_result:
			return ["mob", mob_result] # For attacking
		else:
			return ["normal", false]
	else:
		return ["bad", false]

func mobs_turn():
	for i in get_children():
		if i extends MOB_CLASS and i != player:
			if not i.dead:
				mob_take_turn(i)

func mob_take_turn(mob):
	var mobloc = Vector2(mob.x, mob.y)
	var playerloc = Vector2(player.x, player.y)
	if mob.disposition < 0 and (mobloc - playerloc).length() < 1.4:
		mob.attack(player)
	elif mob.movement == mob.ROAM:
		var i = randi() % 4
		var direction
		if i == 0:
			direction = "up"
		elif i == 1:
			direction = "down"
		elif i == 2:
			direction = "left"
		else:
			direction = "right"
		var walk_type = check_tile(mob, direction)
		if walk_type[0] == "normal":
			mob.move(direction)
			redraw(mob)
	else:
		pass

func _process(delta):
	if direction_press:
		var direction = direction_press
		direction_press = false
		var walk_type = check_tile(player, direction)
		if walk_type[0] == "normal":
			player.move(direction)
			redraw(player)
			mobs_turn()
		elif walk_type[0] == "mob":
			var mob = walk_type[1]
			if mob.disposition < 0:
				player.attack(mob)
				mobs_turn()
			else:
				open_conversation(mob)
		else:
			pass

func _ready():
	player = get_node("/root/game").player
	# Calculate mob location based on initial position
	for i in get_children():
		if (i extends MOB_CLASS and i != player) or i extends TRANSITION_CLASS:
			var position = i.get_pos()
			i.x = int(round(position.x / TILE_SIZE))
			i.y = int(round(position.y / TILE_SIZE))
			redraw(i)
	set_process_input(true)
	set_process(true)

