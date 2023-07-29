extends Control
class_name LeaderboardEntry

@export var rank_label: Label
@export var name_label: Label
@export var score_label: Label

class LeaderboardEntryData:
	var name: String
	var score: int
	
	func _init(name: String = "", score: int = 0):
		self.name = name
		self.score = score

func bind(rank: int, data: LeaderboardEntryData):
	rank_label.text = str(rank)
	name_label.text = data.name.substr(0, 10)
	score_label.text = str(data.score).pad_zeros(4)
