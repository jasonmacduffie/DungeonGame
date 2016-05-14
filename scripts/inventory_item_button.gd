
extends PanelContainer

func _ready():
	pass

func set_values(name, weight):
	get_node("hbox/name").set_text(name)
	get_node("hbox/weight").set_text(str(weight / 1000.0))
