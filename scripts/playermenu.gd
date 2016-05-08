
extends Panel

# member variables here, example:
# var a=2
# var b="textvar"

onready var inventory_list = get_node("tabs").get_node("Inventory").get_node("scroll_area").get_node("itemlist")

func _input(event):
	var valid = event.is_pressed() && !event.is_echo()
	if valid:
		if event.is_action("ui_playermenu") or event.is_action("ui_cancel"):
			leave_menu()

func leave_menu():
	get_tree().set_pause(false)
	hide()



func _ready():
	for i in get_node("/root/game").player.inventory:
		inventory_list.add_item(i['name'])
	set_process_input(true)
