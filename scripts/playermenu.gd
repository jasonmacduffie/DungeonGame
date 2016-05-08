
extends Panel

onready var inventory_list = get_node("tabs").get_node("Inventory").get_node("scroll_area").get_node("itemlist")

func _input(event):
	var valid = event.is_pressed() && !event.is_echo()
	if valid:
		if event.is_action_pressed("ui_playermenu") or event.is_action_pressed("ui_cancel"):
			leave_menu()

func leave_menu():
	accept_event()
	hide()
	set_process_input(false)
	get_tree().set_pause(false)

func open_menu():
	for i in get_node("/root/game").player.inventory:
		inventory_list.add_item(i['name'])
	set_process_input(true)
	show()

func _ready():
	pass
