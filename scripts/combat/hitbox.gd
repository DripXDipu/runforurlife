
class_name Hitbox
extends Area2D

@export var damage: float = 10.0
@export var team: int = 1
@export var one_shot: bool = false

var _already_hit: Array[Area2D] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	_try_hit(area)


func _try_hit(area: Area2D) -> void:
	if not area is Hurtbox:
		return

	if area.team == team:
		return

	if one_shot and area in _already_hit:
		return

	area.receive_hit(damage, self)

	if one_shot:
		_already_hit.append(area)


func start_attack() -> void:
	_already_hit.clear()
	monitoring = true

	await get_tree().physics_frame

	for area in get_overlapping_areas():
		_try_hit(area)


func stop_attack() -> void:
	monitoring = false
