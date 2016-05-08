
extends Node2D

export var next = ""
var x
var y

func _input(event):
	var valid = event.is_pressed() && !event.is_echo()
	if valid:
		if event.is_action("ui_transition"):
			var player = get_parent().player
			if player.x == x and player.y == y:
				print("You changed rooms")

func _ready():
	pass
	set_process_input(true)

