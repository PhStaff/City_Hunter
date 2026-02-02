extends KinematicBody2D

onready var masked_spr: = $Masked
onready var unmasked_spr: = $Unmasked

onready var alert_spr: = $Alert

var SPEED = 100

var direction = Vector2.ZERO

var masked = true
var being_chased = false

var tutorial = true

func _ready():
	pass # Replace with function body.

func _process(delta):
	if tutorial:
		return
	
	move()
	
	if Input.is_action_just_pressed("player_space"):
		masking()

func move(): 
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	input.y = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
	input = input.normalized()
	
	direction = input * SPEED
	
	move_and_slide(direction)

func masking():
	if masked:
		masked = false
		
		masked_spr.visible = false
		unmasked_spr.visible = true
		
		#Soundplayer.play_sound(Soundplayer.MASKED_OFF)
	else:
		masked = true
		
		masked_spr.visible = true
		unmasked_spr.visible = false
		
		#Soundplayer.play_sound(Soundplayer.MASKED_ON)

func set_being_chased(is_chased):
	being_chased = is_chased
	alert_spr.visible = is_chased


func _on_Criminal_Beatbox_body_entered(body):
	body.set_close_to_player(true)

func _on_Criminal_Beatbox_body_exited(body):
	body.set_close_to_player(false)
