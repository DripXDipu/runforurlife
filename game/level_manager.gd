
extends Node

@export var herb_scene: PackedScene
@export var herb_count: int = 3

@export var ground_path: NodePath
@export var door_path: NodePath
@export var counter_path: NodePath

@onready var popup = get_node("../PauseCanvas/Popup")

var collected_herbs: int = 0
var _spawned_herbs: int = 0

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()

	var ground = get_node(ground_path)
	var door = get_node_or_null(door_path)

	if door == null:
		door = get_node_or_null("../Ground/SceneDoor")

	if door != null:
		door.lock_door()
	else:
		push_error("SceneDoor could not be found!")

	for i in range(herb_count):
		var herb = herb_scene.instantiate()
		add_child(herb)

		herb.global_position = _random_herb_position(ground)
		herb.collected.connect(_on_herb_collected)

		_spawned_herbs += 1

	var counter: Label = get_node(counter_path)
	counter.text = "Herbs: 0/" + str(herb_count)


func _random_herb_position(ground: TileMapLayer) -> Vector2:
	var cell_x = _rng.randi_range(
		ground.room.position.x,
		ground.room.end.x - 1
	)

	var cell_y = _rng.randi_range(ground.room.position.y,ground.room.end.y - 1)

	var cell = Vector2i(cell_x, cell_y)

	return ground.to_global(ground.map_to_local(cell))


func _on_herb_collected(_herb: Area2D) -> void:
	collected_herbs += 1

	var counter: Label = get_node(counter_path)
	counter.text = "Herbs: " + str(collected_herbs) + "/" + str(herb_count)

	if collected_herbs >= herb_count:
		_unlock_door()
		popup.show_message("Door unlocked! Press E to open.")
	else:
		popup.show_message(str(herb_count - collected_herbs) + " more herbs needed!")


func _unlock_door() -> void:
	var door = get_node_or_null(door_path)

	if door == null:
		door = get_node_or_null("../Ground/SceneDoor")

	if door != null:
		door.unlock_door()
		print("All herbs collected! Door unlocked.")
	else:
		push_error("SceneDoor could not be found!")
