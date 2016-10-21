
extends VBoxContainer

const INVBUTTON = preload("res://scenes/inventory_item_button.tscn")

func _ready():
	pass

func add_item(id):
	var item = get_node("/root/game").select_item(id)
	var x = INVBUTTON.instance()
	x.set_values(item['name'], item['weight'])
	add_child(x)
