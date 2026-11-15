
extends Node

@export var survival_time: float = 30.0

@onready var timer_label: Label = get_node("../PauseCanvas/SurvivalTimer")

var time_left: float = 30.0
var level_finished: bool = false


func _ready() -> void:
	time_left = survival_time
	update_timer()


func _process(delta: float) -> void:
	if level_finished:
		return

	time_left -= delta
	if time_left <= 0:
		time_left = 0
		level_finished = true
		update_timer()
		win_level()
		return

	update_timer()
func update_timer() -> void:
	var minutes := int(time_left) / 60
	var seconds := int(time_left) % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]


func win_level() -> void:
	print("You survived!")
	get_tree().change_scene_to_file("res://game/won.tscn")
