extends Panel

onready var option_race = get_node("option_race")

# Character has 16 pts to distribute

func add_races():
	var races = ["Human", "Roandan", "Dokoran", "Hermadon", "Nathulan", "Treddan"]
	for i in races:
		option_race.add_item(i)

func _ready():
	add_races()
