
extends Node2D

const TILE_SIZE = 64
const tile_types = \
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
	item.set_pos(Vector2(x * TILE_SIZE, y * TILE_SIZE))

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
	
	var tile_result = mob.can_walk(tile_types[get_node("tiles").get_cell(x,y)])
	var mob_result = false

	if tile_result:
		if mob_result:
			return ["mob", false] # For attacking
		else:
			return ["normal", false]
	else:
		return ["bad", false]

func _process(delta):
	if direction_press:
		var direction = direction_press
		direction_press = false
		var walk_type = check_tile(player, direction)
		if walk_type[0] == "normal":
			player.move(direction)
			redraw(player)
		else:
			pass

func _ready():
	player = get_node("/root/game").player
	set_process_input(true)
	set_process(true)