
class_name EnemyBrain
extends Node

signal state_changed(from: StringName, to: StringName)
signal target_acquired(target: Node2D)
signal target_lost
signal attacked(target: Node2D)

const IDLE := &"idle"
const CHASE := &"chase"
const ATTACK := &"attack"
const RETURN := &"return"

@export var move_speed: float = 90.0
@export var chase_speed: float = 140.0
@export var detect_radius: float = 500.0
@export var attack_radius: float = 5.0
@export var give_up_radius: float = 1000.0
@export var attack_cooldown: float = 1.0
@export var attack_duration: float = 0.25
@export var target_group: StringName = &"player"
@export var enabled: bool = true

var state: StringName = IDLE
var target: Node2D = null
var home := Vector2.ZERO

var _body: CharacterBody2D = null
var _health: Node = null
var _target_id := 0
var _cooldown := 0.0
var _swing: Area2D = null
var _swing_left := 0.0


func _ready() -> void:
	_body = get_parent() as CharacterBody2D

	if _body == null:
		push_warning("EnemyBrainLite needs a CharacterBody2D parent.")
		set_physics_process(false)
		return

	home = _body.global_position

	for c in _body.get_children():
		if c != self and c.has_method("is_alive"):
			_health = c
			break


func _physics_process(delta: float) -> void:
	if not enabled:
		if _swing_left > 0.0:
			_swing_left = 0.0
			_arm(false)
		return

	if _health_dead():
		if _swing_left > 0.0:
			_swing_left = 0.0
			_arm(false)

		if target != null:
			_drop_target()

		_switch(IDLE)
		_body.velocity = Vector2.ZERO
		_body.move_and_slide()
		return

	_cooldown = maxf(0.0, _cooldown - delta)
	_tick_swing(delta)
	_update_target()

	match state:
		IDLE:
			_body.velocity = Vector2.ZERO

		CHASE:
			_do_chase()

		ATTACK:
			_do_attack()

		RETURN:
			_switch(CHASE)
			_do_chase()

	_body.move_and_slide()


func set_state(to: StringName) -> void:
	_switch(to)


func _health_dead() -> bool:
	return _health != null \
		and is_instance_valid(_health) \
		and not bool(_health.call("is_alive"))


func _do_chase() -> void:
	if target == null:
		_body.velocity = Vector2.ZERO
		return

	var distance := _body.global_position.distance_to(target.global_position)

	if distance <= attack_radius:
		_body.velocity = Vector2.ZERO
		_switch(ATTACK)
		return

	var direction := _body.global_position.direction_to(target.global_position)
	_body.velocity = direction * chase_speed


func _do_attack() -> void:
	_body.velocity = Vector2.ZERO

	if target == null:
		_switch(IDLE)
		return

	var distance := _body.global_position.distance_to(target.global_position)

	if distance > attack_radius * 1.2:
		_switch(CHASE)
		return

	if _cooldown <= 0.0:
		_cooldown = attack_cooldown
		_swing = _hitbox()

	if _swing == null:
		push_warning("EnemyBrainLite: Could not find enemy hitbox!")
		return

	_swing_left = attack_duration
	_arm(true)

	attacked.emit(target)


func _update_target() -> void:
	if target != null and is_instance_valid(target):
		_target_id = target.get_instance_id()
		return

	var best: Node2D = null

	for n in get_tree().get_nodes_in_group(target_group):
		if n is Node2D and is_instance_valid(n) and n != _body:
			best = n
			break

	if best != null:
		target = best
		_target_id = best.get_instance_id()

		if state == IDLE:
			_switch(CHASE)

		target_acquired.emit(best)
	else:
		if state == CHASE or state == ATTACK:
			_switch(IDLE)


func _drop_target() -> void:
	target = null
	_target_id = 0
	target_lost.emit()


func _hitbox() -> Area2D:
	for c in _body.get_children():
		if c is Area2D and "team" in c and ("damage" in c or "base_damage" in c):
			return c as Area2D

	return null


func _tick_swing(delta: float) -> void:
	if _swing_left <= 0.0:
		return

	_swing_left -= delta

	if _swing_left <= 0.0:
		_arm(false)


func _arm(on: bool) -> void:
	if _swing != null and is_instance_valid(_swing):
		if on:
			_swing.start_attack()
		else:
			_swing.stop_attack()


func _switch(to: StringName) -> void:
	if to == state:
		return

	var from := state
	state = to

	state_changed.emit(from, to)
