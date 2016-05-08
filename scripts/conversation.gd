
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
			# Do something
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
	set_process_input(true)
