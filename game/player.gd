extends CharacterBody2D

@onready var _sprite: AnimatedSprite2D = $Sprite




func _physics_process(_delta: float) -> void:
	if velocity.length_squared() > 1.0:
		_sprite.play("run")
		if absf(velocity.x) > 0.0:
			_sprite.flip_h = velocity.x < 0.0
	else:
		_sprite.play("idle")

func _on_health_lite_died() -> void:
	var current_level := get_tree().current_scene.scene_file_path
	get_tree().set_meta("previous_level", current_level)
	get_tree().call_deferred("change_scene_to_file","res://game/gameover.tscn")
