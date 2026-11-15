extends Control

@export var menu_music: AudioStream
@onready var settings_panel = $CenterContainer/VBoxContainer/settingsPanel

func _ready() -> void:
	AudioManager.play_music(menu_music)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://game/level1.tscn")
func _on_settings_pressed() -> void:
	settings_panel.show()

func _on_exit_pressed() -> void:
	get_tree().quit()
