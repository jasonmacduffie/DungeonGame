
extends Panel

var conversation_tree = {
	"initial" : "default",
	"options" : []
}
var npc_name = "default"
var current_topic
var avatar_location = "res://images/anonymous_avatar.png"

func _input(event):
	var valid = event.is_pressed() && !event.is_echo()
	if valid:
		if event.is_action("ui_accept"):
			enter_option()

func enter_option():
	var i = get_node("choices").get_selected()
	if (i + 1) == get_node("choices").get_button_count():
		get_tree().set_pause(false)
		queue_free()
		
	pass

func set_topic(d):
	# Set initial to the text box
	for i in d['options']:
		# For each option, add a button
		get_node("choices").add_button(i['description'])
	get_node("choices").add_button("Good bye")

func _ready():
	get_node("name").set_text(npc_name)
	get_node("avatar").set_texture(load(avatar_location))
	set_topic(conversation_tree)
	get_node("choices").grab_focus()
	set_process_input(true)
