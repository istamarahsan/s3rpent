extends MarginContainer
class_name LeaderboardEntries

@export var initial_size: Vector2
@export var initial_position: Vector2
@export var final_size: Vector2
@export var final_position: Vector2
@export var entries_container: Container

const entry_scene: PackedScene = preload("res://leaderboard/leaderboard_entry.tscn")

func bind(data: Array[LeaderboardEntry.LeaderboardEntryData]):
	for child in entries_container.get_children():
		child.queue_free()
	for i in range(data.size()):
		var node := _create_entry(i+1, data[i])
		entries_container.add_child(node)

func animate_show():
	size = initial_size
	position = initial_position
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	tween.tween_property(self, "size", final_size, 0.8)
	tween.tween_property(self, "position", final_position, 0.8)

func _ready():
	size = initial_size
	position = initial_position

func _create_entry(rank: int, data: LeaderboardEntry.LeaderboardEntryData) -> LeaderboardEntry:
	var node := entry_scene.instantiate() as LeaderboardEntry
	node.bind(rank, data)
	return node
