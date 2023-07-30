extends MarginContainer

@export var initial_size: Vector2
@export var initial_position: Vector2
@export var final_size: Vector2
@export var final_position: Vector2
@export var entries_container: Container
@export var loading: Control

const entry_scene: PackedScene = preload("res://leaderboard/leaderboard_entry.tscn")

func _ready():
	size = initial_size
	position = initial_position

func _on_fetch_scores_request_completed(result, response_code, headers, body):
	if response_code != 200:
		return
	
	loading.visible = false
	
	for child in entries_container.get_children():
		child.queue_free()
	
	var entries := _parse_response_data(body)
	entries.sort_custom(func(a, b): return a.score > b.score)
	for i in range(entries.size()):
		var node := _create_entry(i+1, entries[i])
		entries_container.add_child(node)
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	tween.tween_property(self, "size", final_size, 0.8)
	tween.tween_property(self, "position", final_position, 0.8)

func _parse_response_data(body) -> Array:
	var json = JSON.parse_string(body.get_string_from_utf8())
	var entries = json["data"]
	return entries.map(func(entry):
		return LeaderboardEntry.LeaderboardEntryData.new(entry["name"], int(entry["score"])))

func _create_entry(rank: int, data: LeaderboardEntry.LeaderboardEntryData) -> LeaderboardEntry:
	var node := entry_scene.instantiate() as LeaderboardEntry
	node.bind(rank, data)
	return node
