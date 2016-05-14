
extends Panel

onready var invlist = get_node("tabs/Inventory/ScrollContainer/invlist")

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
		add_invlist_item(i)
	set_process_input(true)
	show()

func _ready():
	for i in range(8):
		invlist.add_item('old_longsword')
