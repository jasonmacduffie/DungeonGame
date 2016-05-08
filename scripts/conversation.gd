
extends Panel

var conversation_tree = {
	"initial" : "default",
	"options" : []
}
var npc_name = "default"
var current_topic
var avatar_location = "res://images/anonymous_avatar.png"

func _ready():
	current_topic = conversation_tree
	get_node("name").set_text(npc_name)
	get_node("avatar").set_texture(load(avatar_location))
