extends Node2D
@export var level_music: AudioStream

func _ready() -> void:
	AudioManager.play_music(level_music, 1.0)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			$PauseCanvas/PauseMenu.close_pause()
		else:
			$PauseCanvas/PauseMenu.open_pause()
