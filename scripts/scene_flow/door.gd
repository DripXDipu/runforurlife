
class_name SceneDoor
extends Area2D

signal traveled(by: Node)

@export_file("*.tscn") var target_scene: String
@export var target_spawn: StringName = &""
@export var enabled: bool = true

var unlocked: bool = false
var opening: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _player_in: Node = null
var _wait_exit := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	anim.animation_finished.connect(_on_animation_finished)
	lock_door()


func lock_door() -> void:
	enabled = false
	unlocked = false
	opening = false
	anim.play("close")


func unlock_door() -> void:
	unlocked = true
	enabled = true


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in = body

	if _scene_flow().just_placed():
		_wait_exit = true
		return

	if unlocked:
		open_door()
	else:
		print("Collect 3 herbs to unlock this door!")


func _on_body_exited(body: Node) -> void:
	if body == _player_in:
		_player_in = null
		_wait_exit = false
		opening = false


func open_door() -> void:
	if opening or not unlocked or not enabled or _wait_exit:
		return

	opening = true
	anim.play("open")


func _on_animation_finished() -> void:
	if anim.animation != "open":
		return

	if _player_in != null and is_instance_valid(_player_in):
		try_travel(_player_in)


func try_travel(by: Node) -> void:
	if not enabled or not unlocked or target_scene.is_empty():
		return

	var scene_flow = _scene_flow()

	if scene_flow == null or scene_flow.is_changing():
		return

	traveled.emit(by)
	scene_flow.change_scene(target_scene, target_spawn)


const SCENE_FLOW := preload("res://scripts/scene_flow/scene_flow.gd")


static func _scene_flow() -> SCENE_FLOW:
	return (Engine.get_main_loop() as SceneTree).root.get_node_or_null(^"SceneFlow") as SCENE_FLOW
