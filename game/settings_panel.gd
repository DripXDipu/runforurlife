
extends PanelContainer

var music_slider: HSlider
var sfx_slider: HSlider
var music_label: Label
var sfx_label: Label

func _ready() -> void:
	_build_settings()
	hide()

func _build_settings() -> void:
	var layout := VBoxContainer.new()
	add_child(layout)

	var title := Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	music_label = Label.new()
	layout.add_child(music_label)

	music_slider = HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.01
	music_slider.value = AudioManager.get_bus_volume("Music")
	music_slider.value_changed.connect(_on_music_changed)
	layout.add_child(music_slider)

	sfx_label = Label.new()
	layout.add_child(sfx_label)

	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.01
	sfx_slider.value = AudioManager.get_bus_volume("SFX")
	sfx_slider.value_changed.connect(_on_sfx_changed)
	layout.add_child(sfx_slider)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(hide)
	layout.add_child(close_button)

	_update_labels()

func _on_music_changed(value: float) -> void:
	AudioManager.set_bus_volume("Music", value)
	_update_labels()

func _on_sfx_changed(value: float) -> void:
	AudioManager.set_bus_volume("SFX", value)
	_update_labels()

func _update_labels() -> void:
	music_label.text = "Music: " + str(roundi(music_slider.value * 100)) + "%"
	sfx_label.text = "Sound Effects: " + str(roundi(sfx_slider.value * 100)) + "%"
