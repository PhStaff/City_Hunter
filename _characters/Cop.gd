extends KinematicBody2D

signal ended_chase
signal player_caught
signal new_goal_cop(cop)

export (int, LAYERS_2D_NAVIGATION) var nav_layer = 1

onready var alert_spr: = $Alert

var SPEED = 2
var ARRIVAL_TOLERANCE = 5
var START_POINT = null

var current_target = null

var path = null 
var path_idx = 0

var chases_player = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	if current_target == null:
		set_new_goal()
	
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
	
	if global_position.distance_to(path[path_idx]) <= ARRIVAL_TOLERANCE:
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
	emit_signal("new_goal_cop", self)


func _on_Kill_Player_body_entered(body):
	if body.masked or body.being_chased:
		emit_signal("player_caught")
