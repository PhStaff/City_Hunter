extends KinematicBody2D

signal criminal_beaten
signal new_goal(crim)

onready var hidden_spr: = $Hidden
onready var found_spr: = $Found

onready var beaten_spr: = $Beaten

export (int, LAYERS_2D_NAVIGATION) var nav_layer = 1

var SPEED = 5
var START_POINT = null
var GOAL_POINT = null

var POT_GOAL1 = null
var POT_GOAL2 = null
var POT_GOAL3 = null
var POT_GOAL4 = null

var START = 0
var GOAL = 1

var current_des = GOAL
var current_target = null

var path = null 
var path_idx = 0
var arrival_tolerance = 5

var beatable = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("player_action") and beatable:
		beaten_up()
	
	if current_target == null:
		set_new_goal()
	
	if not path:
		set_new_path()
	else:
		move_towards_goal(delta)

func move_towards_goal(delta):
	var direction = (path[path_idx] - global_position).normalized()
	var movement = direction * SPEED
	move_and_collide(movement)
	
	if global_position.distance_to(path[path_idx]) <= arrival_tolerance:
		path_idx += 1
	
	if path_idx == path.size():
		set_new_goal()

func set_new_path():
	path = Navigation2DServer.map_get_path(get_world_2d().navigation_map, global_position, current_target, false, nav_layer)
	path_idx = 0

func set_new_goal():
	path = null
	emit_signal("new_goal", self)
	return
	
	var rand_nr = randi() % 4
	if rand_nr == 0:
		current_target = POT_GOAL1.position
	elif rand_nr == 1:
		current_target = POT_GOAL2.position
	elif rand_nr == 2:
		current_target = POT_GOAL3.position
	elif rand_nr == 3:
		current_target = POT_GOAL4.position

func beaten_up():
	emit_signal("criminal_beaten")
	Soundplayer.play_sound(Soundplayer.BEATING)
	queue_free()
	beaten_spr.visible = true


func _on_Area2D_body_entered(body):
	hidden_spr.visible = false
	found_spr.visible = true
