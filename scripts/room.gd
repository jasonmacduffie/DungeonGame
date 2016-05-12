
extends Node2D

const MOB_CLASS = preload("res://scripts/mob.gd")
const TRANSITION_CLASS = preload("res://scripts/transition.gd")
const CONTAINER_CLASS = preload("res://scripts/container.gd")
const CONVERSATION_SCENE = preload("res://scenes/conversation.xscn")
const TILE_SIZE = 64
const TILE_TYPES = \
{
	-1: "impossible", # Nothing can pass
	 0: "impossible",
	 1: "solid", # Only ghosts can pass
	 2: "walkable", # Anything can pass
	 3: "solid",
	 4: "walkable",
	 5: "water" # Flying, aquatic can pass
}
# Another type, lava, only flying and magmic can pass

# Speed to turn probabilities, in percentile
# These approximately fit a square root curve
const SPEED_PROBABILITY = \
[
	0,
	0,
	13,
	19,
	24,
	28,
	31,
	34,
	37,
	40,
	42
]

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
		elif event.is_action("ui_playermenu"):
			bring_player_menu()

func get_mobs():
	var result = []
	for i in get_children():
		if i extends MOB_CLASS:
			result.append(i)
	return result

func get_containers():
	var result = []
	for i in get_children():
		if i extends CONTAINER_CLASS:
			result.append(i)
	return result

func bring_player_menu():
	var pm = player.get_node("canvas").get_node("playermenu")
	pm.open_menu()
	get_tree().set_pause(true)

func remove_child_player():
	# Used to easily remove the player when changing rooms
	remove_child(player)

func redraw(item):
	# This method displays the item in the correct coordinate
	var x = item.x
	var y = item.y
	item.set_pos(Vector2((x + 0.5) * TILE_SIZE, (y + 0.5) * TILE_SIZE))

func opposite_dir(direction):
	if direction == "up":
		return "down"
	elif direction == "down":
		return "up"
	elif direction == "left":
		return "right"
	else:
		return "left"

func open_conversation(mob):
	var conv = CONVERSATION_SCENE.instance()
	conv.npc = mob
	conv.npc_name = mob.name
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
	var container_result = false
	
	if not tile_result:
		return ["bad", false]
	
	for i in get_mobs():
		if i.x == x and i.y == y:
			mob_result = i
			break
	if mob_result:
		return ["mob", mob_result]
	
	for i in get_containers():
		if i.x == x and i.y == y:
			container_result = i
			break
	if container_result:
		return ["container", container_result]
	
	return ["normal", false]

func mobs_turn():
	for i in get_mobs():
		if not (i.is_player or i.dead):
			mob_take_turn(i)
			# Based on speed, the mob may take a turn again
			while (randi() % 100 < SPEED_PROBABILITY[i.effective_speed()]):
				mob_take_turn(i)

func mob_take_turn(mob):
	var mobloc = Vector2(mob.x, mob.y)
	# Check whether the mob can attack
	for i in get_mobs():
		if mob != i and mob.in_attack_range(i) and mob.is_enemy(i):
			mob.melee_attack(i)
			return
	# Otherwise, move
	if mob.movement == mob.ROAM:
		wander_mob(mob)
	elif mob.movement == mob.SEARCH:
		for i in get_mobs():
			if mob != i and mob.in_vision_range(i) and mob.is_enemy(i):
				var dirs = mob.direction_towards(i)
				var walk_type = check_tile(mob, dirs[0])
				if walk_type[0] == "normal":
					move_mob(mob, dirs[0])
				else:
					move_mob(mob, dirs[1])
				return
		wander_mob(mob)

func wander_mob(mob):
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
	move_mob(mob, direction)

func move_mob(mob, dir):
	var walk_type = check_tile(mob, dir)
	if walk_type[0] == "normal":
		mob.move(dir)
		redraw(mob)

func _process(delta):
	if direction_press:
		var direction = direction_press
		direction_press = false
		var walk_type = check_tile(player, direction)
		assert(walk_type[0] in ["bad", "normal", "mob", "container"])
		if walk_type[0] == "bad":
			player.face(direction)
		elif walk_type[0] == "normal":
			move_mob(player, direction)
			if (randi() % 100 >= SPEED_PROBABILITY[player.effective_speed()]):
				mobs_turn()
		elif walk_type[0] == "mob":
			var mob = walk_type[1]
			if mob.disposition < 0:
				player.face(direction)
				mob.face(opposite_dir(direction))
				player.melee_attack(mob)
				if (randi() % 100 >= SPEED_PROBABILITY[player.effective_speed()]):
					mobs_turn()
			else:
				player.face(direction)
				mob.face(opposite_dir(direction))
				open_conversation(mob)
		elif walk_type[0] == "container":
			player.face(direction)
		else:
			print("walk_type not understood")

func _ready():
	player = get_node("/root/game").player
	# Calculate mob location based on initial position
	for i in get_children():
		if (i extends MOB_CLASS and i != player) or i extends TRANSITION_CLASS or i extends CONTAINER_CLASS:
			var position = i.get_pos()
			i.x = int(round((position.x - 32) / TILE_SIZE))
			i.y = int(round((position.y - 32) / TILE_SIZE))
			# Check if the NPC is dead already
			if i extends MOB_CLASS and i.id != "respawnable" and i.id in get_node("/root/game").dead_npcs:
				i.start_dead()
			redraw(i)
	set_process_input(true)
	set_process(true)

