class_name Health
extends Node

signal damaged(amount: float, source: Node)
signal healed(amount: float)
signal died

@export var max_health: float = 100.0
@export var remove_on_death: bool = false
@export var flash_on_hit: bool = true
@export var flash_color: Color = Color(2.5, 2.5, 2.5)

var current: float = -1.0
var _flash_tween: Tween
var _rest_modulate := Color.WHITE


func _ready() -> void:
	_ensure_init()


func _ensure_init() -> void:
	if current < 0.0:
		current = max_health


func take_damage(amount: float, source: Node = null) -> void:
	_ensure_init()

	if amount <= 0.0 or not is_alive():
		return

	current = maxf(0.0, current - amount)
	damaged.emit(amount, source)

	if current <= 0.0:
		died.emit()

		if remove_on_death:
			_remove_body()
	elif flash_on_hit:
		_flash()


func heal(amount: float) -> void:
	_ensure_init()

	if amount <= 0.0 or not is_alive():
		return

	current = minf(max_health, current + amount)
	healed.emit(amount)


func revive(to: float = -1.0) -> void:
	current = max_health if to < 0.0 else minf(max_health, to)


func is_alive() -> bool:
	_ensure_init()
	return current > 0.0


func fraction() -> float:
	_ensure_init()
	return current / max_health if max_health > 0.0 else 0.0


func _remove_body() -> void:
	var body: Node = get_parent()

	if body == null or body is Viewport:
		body = self

	body.call_deferred("queue_free")


func _flash() -> void:
	var body := get_parent() as CanvasItem

	if body == null or not is_inside_tree():
		return

	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	else:
		_rest_modulate = body.modulate

	body.modulate = _rest_modulate * flash_color

	_flash_tween = create_tween()
	_flash_tween.tween_property(body, "modulate", _rest_modulate, 0.25)
