extends Control

@onready var message_label: Label = $Panel/Label

func _ready() -> void:
	hide()

func show_message(message: String) -> void:
	message_label.text = message
	show()

	await get_tree().create_timer(2.5).timeout
	hide()
