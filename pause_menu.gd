
extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func open_pause() -> void:
	show()
	get_tree().paused = true

func close_pause() -> void:
	get_tree().paused = false
	hide()

func _on_resume_pressed() -> void:
	close_pause()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file","res://game/main_menu.tscn")
