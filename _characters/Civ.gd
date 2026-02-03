extends KinematicBody2D

signal player_found

export (int, LAYERS_2D_NAVIGATION) var nav_layer = 1

onready var alert_spr: = $Alert

var SPEED = randi() % 5
var ARRIVAL_TOLERANCE = 5
var START_POINT = null
var GOAL_POINT = null

var current_target = null

var path = null 
var path_idx = 0
var path_dir = 1

func _ready():
	pass # Replace with function body.

func _process(delta):
	if current_target == null:
		current_target = GOAL_POINT
	
	if not path:
		set_new_path()
	else:
		move_towards_goal()

func move_towards_goal():
	var direction = (path[path_idx] - global_position).normalized()
	var movement = direction * SPEED
	move_and_collide(movement)
	
	if global_position.distance_to(path[path_idx]) <= ARRIVAL_TOLERANCE:
		path_idx += (1 * path_dir)
		if path_idx == -1 or path_idx == path.size():
			set_new_goal()
			path_idx += (1 * path_dir)

func set_new_path():
	path = Navigation2DServer.map_get_path(get_world_2d().navigation_map, global_position, current_target, false, nav_layer)
	path_idx = 0

func set_new_goal():
	if !path:
		return
	
	path_dir *= -1


func _on_Player_Detection_body_entered(body):
	if body.masked or body.being_chased:
		emit_signal("player_found")
		alert_spr.visible = true

func _on_Player_Detection_body_exited(body):
	alert_spr.visible = false
