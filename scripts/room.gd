
extends Node2D

const TILE_SIZE = 64

var player
var direction_press = false

func _input(event):
	var valid = event.is_pressed() && !event.is_echo()
	if valid:
		print(event)
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
	var y = -item.y
	item.set_pos(Vector2(x * TILE_SIZE, y * TILE_SIZE))

func _process(delta):
	if direction_press:
		player.move(direction_press)
		direction_press = false
#	if stop == true:
#		stop = false

func _ready():
	player = get_node("/root/game").player
	set_process_input(true)
	set_process(true)