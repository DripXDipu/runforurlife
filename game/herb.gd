
extends Area2D

signal collected(herb: Area2D)

var _collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _collected:
		return

	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	_collected = true
	collected.emit(self)
	queue_free()
