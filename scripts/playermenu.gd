
extends Panel

onready var invpanel = get_node("tabs/Inventory")
onready var invlist = get_node("tabs/Inventory/invlist")

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

func add_invlist_item(id):
	var item = get_node("/root/game").select_item(id)
	var y = invlist.get_button_count()
	invlist.add_button(item['name'])
	var l = Label.new()
	invlist.add_child(l)
	l.set_pos(Vector2(450 , 29 * y + 4))
	l.set_text(str(item['weight'] / 1000.0) + " kg")

func _ready():
	pass
