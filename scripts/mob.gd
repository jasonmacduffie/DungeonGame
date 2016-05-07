
extends Node2D

var x = 0
var y = 0

var walkable = ["walkable"]

func _ready():
	pass

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

