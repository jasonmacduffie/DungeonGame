
extends Panel

func _ready():
	get_node("button_new").grab_focus()

func _on_button_new_pressed():
	get_node("/root/game").new_game()

func _on_button_load_pressed():
	pass

func _on_button_options_pressed():
	pass

func _on_button_credits_pressed():
	pass

func _on_button_exit_pressed():
	get_tree().quit()

