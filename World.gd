extends Node2D

const Civ = preload("res://_characters/Civ.tscn")
const Crim = preload("res://_characters/Criminal.tscn")
const Cop = preload("res://_characters/Cop.tscn")

onready var player: = $Player

onready var cops: = $Cops
onready var cooldown: = $Cooldown

onready var start1: = $Starts/Start_Civ1
onready var start2: = $Starts/Start_Civ2
onready var start3: = $Starts/Start_Civ3
onready var start4: = $Starts/Start_Civ4

onready var goal1: = $Goals/Goal_Civ1
onready var goal2: = $Goals/Goal_Civ2
onready var goal3: = $Goals/Goal_Civ3
onready var goal4: = $Goals/Goal_Civ4

onready var goal_cop1: = $Goals/Goal_Cop1
onready var goal_cop2: = $Goals/Goal_Cop2
onready var goal_cop3: = $Goals/Goal_Cop3
onready var goal_cop4: = $Goals/Goal_Cop4

onready var crime_spots: = $Crime_Spots
onready var goal_crim1: = $Crime_Spots/Goal_Crim1
onready var goal_crim2: = $Crime_Spots/Goal_Crim2
onready var goal_crim3: = $Crime_Spots/Goal_Crim3
onready var goal_crim4: = $Crime_Spots/Goal_Crim4

onready var npc_group: = $NPCs

onready var crime_text: = $Textlabels/Crime_Counter
onready var game_over_text: = $Textlabels/Game_Over
onready var game_beaten_text: = $Textlabels/Game_Beaten
onready var restart_text: = $Textlabels/Restart

onready var tutorial_pic: = $Tutorial

var CIV_LIMIT = 200
var COP_LIMIT = 10
var CRIM_LIMIT = 10

var civ_current = 0
var cop_current = 0
var crim_current = 0
var crim_spawning = true

var alarmed_cops = 0

var game_over = false
var game_won = false

var tutorial = true

func _ready():
	if tutorial:
		tutorial_pic.visible = true

func _process(delta):
	if tutorial:
		if Input.is_action_just_pressed("player_space"):
			player.tutorial = false
			tutorial_pic.visible = false
			tutorial = false
		
		return
	
	crime_text.text = "Criminals left: " + str(crim_current)
	
	if game_over or game_won:
		if Input.is_action_just_pressed("game_restart"):
			get_tree().reload_current_scene()
	
	spawn_civ()
	spawn_crim()
	spawn_cop()

func spawn_civ():
	if civ_current > CIV_LIMIT:
		return
	
	var rand_nr
	var new_civ = Civ.instance()
	add_child(new_civ)
	#npc_group.add_child(new_civ)
	assign_start_point(set_random_point(), new_civ)
	assign_goal_civ_point(set_random_point(), new_civ)
	
	new_civ.SPEED = randi() % 4 + 1
	
	civ_current += 1
	
	new_civ.connect("player_found", self, "_on_Civ_player_found")

func spawn_crim():
	if crim_current > CRIM_LIMIT or !crim_spawning:
		crim_spawning = false
		return
	
	var rand_nr
	var new_crim = Crim.instance()
	#npc_group.add_child(new_crim)
	add_child(new_crim)
	assign_start_point(set_random_point(), new_crim)
	assign_goal_crim_point(set_random_point(), new_crim)
	new_crim.POT_GOAL1 = goal_crim1
	new_crim.POT_GOAL2 = goal_crim2
	new_crim.POT_GOAL3 = goal_crim3
	new_crim.POT_GOAL4 = goal_crim4
	
	new_crim.SPEED = 1
	
	crim_current += 1
	
	new_crim.connect("criminal_beaten", self, "_on_Crim_beaten_up")
	new_crim.connect("new_goal", self, "_on_Crim_new_goal")

func spawn_cop():
	if cop_current > COP_LIMIT:
		return
	
	var rand_nr
	var new_cop = Cop.instance()
	cops.add_child(new_cop)
	assign_start_point(set_random_point(), new_cop)
	new_cop.POT_GOAL1 = goal_cop1
	new_cop.POT_GOAL2 = goal_cop2
	new_cop.POT_GOAL3 = goal_cop3
	new_cop.POT_GOAL4 = goal_cop4
	
	new_cop.SPEED = 2
	
	cop_current += 1
	
	new_cop.connect("ended_chase", self, "_on_Cop_ended_chase")
	new_cop.connect("player_caught", self, "_on_Cop_caught_player")

func set_random_point():
	return randi() % 4

func assign_start_point(rand_nr, new_civ):
	if rand_nr == 0:
		new_civ.position = start1.position
		new_civ.START_POINT = start1.position
	elif rand_nr == 1:
		new_civ.position = start2.position
		new_civ.START_POINT = start2.position
	elif rand_nr == 2:
		new_civ.position = start3.position
		new_civ.START_POINT = start3.position
	elif rand_nr == 3:
		new_civ.position = start4.position
		new_civ.START_POINT = start4.position

func assign_goal_civ_point(rand_nr, new_civ):
	if rand_nr == 0:
		new_civ.GOAL_POINT = goal1.position
	elif rand_nr == 1:
		new_civ.GOAL_POINT = goal2.position
	elif rand_nr == 2:
		new_civ.GOAL_POINT = goal3.position
	elif rand_nr == 3:
		new_civ.GOAL_POINT = goal4.position

func assign_goal_crim_point(rand_nr, new_civ):
	if rand_nr == closest_crime_spot():
		rand_nr = (rand_nr + 1) % 4
	
	if rand_nr == 0:
		new_civ.current_target = goal_crim1.position
	elif rand_nr == 1:
		new_civ.current_target = goal_crim2.position
	elif rand_nr == 2:
		new_civ.current_target = goal_crim3.position
	elif rand_nr == 3:
		new_civ.current_target = goal_crim4.position

func closest_crime_spot():
	if !is_instance_valid(player):
		return 5
	
	var index_return = 0
	var distance = 10000
	var distance_temp 
	var index = 0
	
	for spot in crime_spots.get_children():
		distance_temp = player.global_position.distance_to(spot.global_position)
		if distance_temp < distance:
			distance = distance_temp
			index_return = index
		
		index += 1
	
	return index_return

func assign_goal_cop_point(rand_nr, new_civ):
	if rand_nr == 0:
		new_civ.GOAL_POINT = goal_cop1.position
	elif rand_nr == 1:
		new_civ.GOAL_POINT = goal_cop2.position
	elif rand_nr == 2:
		new_civ.GOAL_POINT = goal_cop3.position
	elif rand_nr == 3:
		new_civ.GOAL_POINT = goal_cop4.position


func _on_Civ_player_found():
	if game_won:
		return
	
	if !cooldown.is_stopped():
		return
	
	player.set_being_chased(true)
	Soundplayer.play_sound(Soundplayer.CHASE)
	
	for cop in cops.get_children():
		if !cop.chases_player:
			alarmed_cops += 1
		
		cop.chase_player(player.global_position)
		#print(alarmed_cops)
	
	cooldown.start()

func _on_Cop_ended_chase():
	alarmed_cops -= 1
	
	if !is_instance_valid(player):
		return
	
	#print(alarmed_cops)
	if alarmed_cops == 0:
		#Soundplayer.play_sound(Soundplayer.ESCAPED)
		player.set_being_chased(false)

func _on_Crim_beaten_up():
	crim_current -= 1
	
	if crim_current == 0:
		game_won = true
		game_beaten_text.visible = true
		restart_text.visible = true

func _on_Crim_new_goal(crim):
	assign_goal_crim_point(set_random_point(), crim)

func _on_Cop_caught_player():
	if game_won:
		return
	
	player.queue_free()
	Soundplayer.play_sound(Soundplayer.CAUGHT)
	
	game_over = true
	game_over_text.visible = true
	restart_text.visible = true
