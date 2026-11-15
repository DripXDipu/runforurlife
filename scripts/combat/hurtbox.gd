
class_name Hurtbox
extends Area2D

signal hit(amount: float, source: Node)

@export var team: int = 0
@export var health_path: NodePath

var _health: Health = null
func _ready() -> void:
	if health_path != NodePath():
		_health = get_node_or_null(health_path) as Health

	if _health == null:
		_health = _find_sibling_health()

	if _health != null:
		_health.died.connect(_on_health_died)


func receive_hit(amount: float, source: Node) -> void:
	hit.emit(amount, source)

	if _health != null:
		_health.take_damage(amount, source)


func _on_health_died() -> void:
	pass


func _find_sibling_health() -> Health:
	var p := get_parent()

	if p != null:
		for c in p.get_children():
			if c is Health:
				return c

	return null
