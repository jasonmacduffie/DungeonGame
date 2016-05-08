
extends Node2D

export var next = ""
var x
var y
export var next_x = 0
export var next_y = 0

func _input(event):
	var valid = event.is_pressed() && !event.is_echo()
	if valid:
		if event.is_action("ui_transition"):
			check_player_transition()

func check_player_transition():
	var player = get_parent().get_node("player")
	if player.x == x and player.y == y:
			get_node("/root/game").change_rooms(next,next_x,next_y)

func _ready():
	pass
	set_process_input(true)

