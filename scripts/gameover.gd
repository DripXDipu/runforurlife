extends Control

func _on_retry_pressed() -> void:
	get_tree().paused = false

	var previous_level: String = get_tree().get_meta("previous_level","res://game/level1.tscn")

	get_tree().call_deferred("change_scene_to_file",previous_level)

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file","res://game/main_menu.tscn")
