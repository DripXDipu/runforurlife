class_name SceneSpawnPointLite
extends Marker2D
@export var id: StringName = &"default"
func _ready() -> void:
	add_to_group("scene_spawn")
