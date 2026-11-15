extends Node

signal scene_changing(to_path: String)
signal scene_changed(path: String)
signal faded_out
signal faded_in

@export var fade_time: float = 0.4
@export var fade_color: Color = Color.BLACK

var _fade_layer: CanvasLayer = null
var _fade_rect: ColorRect = null
var _changing := false

var _placed_msec := -100000
var _warned_mismatch := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_scene(path: String, spawn: StringName = &"", fade: bool = true) -> void:
	if _changing or path.is_empty():
		return

	_changing = true
	scene_changing.emit(path)

	if fade and fade_time > 0.0:
		await fade_out()

	var error := get_tree().change_scene_to_file(path)

	if error != OK:
		push_error("SceneFlow: Could not load scene: " + path)
		_changing = false
		if fade and fade_time > 0.0:
			await fade_in()
		return

	await get_tree().process_frame
	await get_tree().process_frame

	place_player(spawn)
	scene_changed.emit(path)

	if fade and fade_time > 0.0:
		await fade_in()

	_changing = false


func place_player(spawn: StringName = &"") -> void:
	var sp := _find_spawn(spawn)

	if sp == null:
		return

	for p in get_tree().get_nodes_in_group("player"):
		if sp is Node2D and p is Node2D:
			p.global_position = sp.global_position
		elif sp is Node3D and p is Node3D:
			_place_3d(p, sp)
		elif p is Node2D or p is Node3D:
			_warn_mismatch(p, sp)

	_placed_msec = Time.get_ticks_msec()


func _place_3d(player: Node3D, sp: Node3D) -> void:
	var forward := -sp.global_basis.z
	var yaw := atan2(-forward.x, -forward.z)

	player.global_position = sp.global_position
	player.global_rotation = Vector3(0.0, yaw, 0.0)

	if player is CharacterBody3D:
		(player as CharacterBody3D).velocity = Vector3.ZERO
	elif player is RigidBody3D:
		(player as RigidBody3D).linear_velocity = Vector3.ZERO

	player.reset_physics_interpolation()


func _warn_mismatch(player: Node, sp: Node) -> void:
	if _warned_mismatch:
		return

	_warned_mismatch = true

	push_warning("SceneFlow: Player '%s' and spawn '%s' have incompatible dimensions."% [player.name, sp.name])


func just_placed(window_msec: int = 400) -> bool:
	return Time.get_ticks_msec() - _placed_msec < window_msec


func current_path() -> String:
	var cs := get_tree().current_scene
	return cs.scene_file_path if cs != null else ""


func is_changing() -> bool:
	return _changing


func _find_spawn(id: StringName) -> Node:
	var pts := get_tree().get_nodes_in_group("scene_spawn")

	if pts.is_empty():
		return null

	if id != &"":
		for pt in pts:
			if pt.get("id") == id:
				return pt

	for pt in pts:
		if pt.get("id") == &"default":
			return pt

	return pts[0]


func fade_out() -> void:
	_ensure_fade()
	_fade_rect.visible = true

	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, fade_time)

	await tw.finished
	faded_out.emit()


func fade_in() -> void:
	_ensure_fade()

	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 0.0, fade_time)

	await tw.finished
	_fade_rect.visible = false
	faded_in.emit()


func _ensure_fade() -> void:
	if _fade_layer != null:
		return

	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100

	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.color = Color(fade_color.r,fade_color.g,fade_color.b,0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.visible = false

	_fade_layer.add_child(_fade_rect)
	add_child(_fade_layer)
