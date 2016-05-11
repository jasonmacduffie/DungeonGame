
extends Node2D

var x = 0
var y = 0
export(StringArray) var initial_items = []
var items = []

func _ready():
	pass
	if initial_items != null:
		items += initial_items


