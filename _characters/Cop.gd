extends KinematicBody2D

signal ended_chase
signal player_caught

export (int, LAYERS_2D_NAVIGATION) var nav_layer = 1

onready var alert_spr: = $Alert

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

var chases_player = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	if current_target == null:
		set_new_goal()
	
	#if Input.is_action_just_pressed("player_space"):
		#set_chasing_player(!alert_spr.visible)
	
	if not path:
		set_new_path()
	else:
		move_towards_goal()

func chase_player(player_pos):
	set_chasing_player(true)
	
	current_target = player_pos
	set_new_path()

func set_chasing_player(chasing_player):
	chases_player = chasing_player
	alert_spr.visible = chasing_player

func move_towards_goal():
	var direction = (path[path_idx] - global_position).normalized()
	var movement = direction * SPEED
	move_and_collide(movement)
	
	if global_position.distance_to(path[path_idx]) <= arrival_tolerance:
		path_idx += 1
	
	#Goal reached
	if path_idx == path.size():
		set_new_goal()
		
		if chases_player:
			set_chasing_player(false)
			emit_signal("ended_chase")

func set_new_path():
	path = Navigation2DServer.map_get_path(get_world_2d().navigation_map, global_position, current_target, false, nav_layer)
	path_idx = 0

func set_new_goal():
	path = null
	
	var rand_nr = randi() % 4
	if rand_nr == 0:
		current_target = POT_GOAL1.position
	elif rand_nr == 1:
		current_target = POT_GOAL2.position
	elif rand_nr == 2:
		current_target = POT_GOAL3.position
	elif rand_nr == 3:
		current_target = POT_GOAL4.position


func _on_Kill_Player_body_entered(body):
	if body.masked or body.being_chased:
		emit_signal("player_caught")
