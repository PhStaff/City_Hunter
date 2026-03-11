class_name CutsceneDirector
extends Node

signal cutscene_action_done

@onready var camera = $Player/Camera2D
@onready var dialogue_manager = $Dialogue_Manager

func _ready() -> void:
	add_to_group("cutscenes")

func call_cutscene_action(method_name: String, args: Array) -> void:
	callv(method_name, args)
	await wait_for_cutscene_action_done()

# This is the same as call_cutscene_action, but with a shorter name
func cca(method_name: String, args: Array) -> void:
	callv(method_name, args)
	await wait_for_cutscene_action_done()

func wait_for_cutscene_action_done() -> void:
	await cutscene_action_done

func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout
	emit_signal("cutscene_action_done")

func wait_and_emit_done(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
	emit_signal("cutscene_action_done")

# Example actions
func move_camera_to_position(starting_position: Vector2, ending_position: Vector2, duration: float) -> void:
	if not camera:
		return
	
	camera.position = starting_position
	var tween = create_tween()
	tween.tween_property(camera, "position", ending_position, duration)
	await tween.finished
	emit_signal("cutscene_action_done")

func zoom_camera(starting_value: Vector2, ending_value: Vector2, duration: float) -> void:
	if not camera:
		return
	
	camera.zoom = starting_value
	var tween = create_tween()
	tween.tween_property(camera, "zoom", ending_value, duration)
	await tween.finished
	emit_signal("cutscene_action_done")

func move_character(character: Node, end_position: Vector2, duration: float) -> void:
	move_character_to_position(character, character.position, character.position + end_position, duration)

func move_character_to_position(character: Node, start_position: Vector2, end_position: Vector2, duration: float) -> void:
	character.position = start_position

	var tween = create_tween()
	tween.tween_property(character, "position", end_position, duration)
	await tween.finished
	
	emit_signal("cutscene_action_done")

func load_dialogue(dialogue_name: String) -> void:
	if not dialogue_manager:
		return
	
	dialogue_manager.show_dialogue(dialogue_name)
	await dialogue_manager.dialogue_done
	emit_signal("cutscene_action_done")

#func change_scene(scene_path: String, hero_position = null, direction: String = Constants.DIRS.DOWN, transition = "fade_normal") -> void:
	#Global.scene_manager.cutscene_map_change_requested(scene_path, hero_position, direction, transition)
	#emit_signal("cutscene_action_done")
