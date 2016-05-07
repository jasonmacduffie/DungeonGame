
extends Node2D

var x = 0
var y = 0

func _ready():
	pass

func move(direction):
	assert(direction in ["up", "down", "left", "right"])
	if direction == "up":
		y += 1
	elif direction == "down":
		y -= 1
	elif direction == "right":
		x += 1
	else:
		x -= 1
	
	# Tell parent scene to redraw the character
	get_parent().redraw(self)
