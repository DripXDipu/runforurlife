class_name TopDownMoverLite
extends Node

signal started_moving
signal stopped_moving

@export var speed: float = 200.0
@export var acceleration: float = 0.0
@export var friction: float = 0.0

@export var action_left: StringName = &"move_left"
@export var action_right: StringName = &"move_right"
@export var action_up: StringName = &"move_up"
@export var action_down: StringName = &"move_down"

@export var input_enabled: bool = true
@export var is_player: bool = true
@export var save_id: String = ""

var _body: CharacterBody2D = null
var _moving := false

const SAVE_GROUPS := ["save_load_contract", "save_load_contract_lite"]


func _ready() -> void:
	_body = get_parent() as CharacterBody2D

	if _body == null:
		push_warning("TopDownMoverLite needs a CharacterBody2D parent.")
		set_physics_process(false)
		return

	if is_player:
		_body.add_to_group("player")

	if save_id != "":
		for g in SAVE_GROUPS:
			add_to_group(g)


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO

	if input_enabled:
		dir = Input.get_vector(action_left, action_right, action_up, action_down)

	var target := dir * speed

	if dir != Vector2.ZERO:
		_body.velocity = _approach(_body.velocity, target, acceleration, delta)
	else:
		_body.velocity = _approach(_body.velocity, Vector2.ZERO, friction, delta)

	_body.move_and_slide()
	_flag_moving(_body.velocity.length_squared() > 1.0)


func _approach(v: Vector2, target: Vector2, rate: float, delta: float) -> Vector2:
	return target if rate <= 0.0 else v.move_toward(target, rate * delta)


func _flag_moving(now: bool) -> void:
	if now == _moving:
		return

	_moving = now

	if _moving:
		started_moving.emit()
	else:
		stopped_moving.emit()


func get_save_id() -> String:
	return "controller_%s" % save_id


func save_state() -> Dictionary:
	if _body == null:
		return {}

	return {"x": _body.global_position.x, "y": _body.global_position.y}


func load_state(data: Dictionary) -> void:
	if _body == null or data.is_empty():
		return

	_body.global_position = Vector2(
		_num(data.get("x", 0.0)),
		_num(data.get("y", 0.0))
	)


static func _num(v: Variant) -> float:
	return float(v) if (v is float or v is int) else 0.0
