extends Label

#this is also bad please change this later

func _ready():
	text = "Food Counter: 0"

func _on_game_food_eaten_updated(food_eaten):
	text = "Food Counter: " + str(food_eaten)
