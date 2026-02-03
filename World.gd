extends Node2D

const Civ = preload("res://_characters/Civ.tscn")
const Crim = preload("res://_characters/Criminal.tscn")
const Cop = preload("res://_characters/Cop.tscn")

onready var player: = $Player

onready var cooldown: = $Cooldown

onready var start_points: = $Starts

onready var civ_goals: = $Civ_Goals
onready var cop_stations: = $Cop_Stations
onready var crime_spots: = $Crime_Spots

onready var cop_group: = $Cops
onready var criminal_group: = $Criminals

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
	Soundplayer.play_sound_city()
	
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
	
	if Input.is_action_just_pressed("player_action") and player.masked:
		for criminal in criminal_group.get_children():
			if !criminal.close_to_player:
				continue
			
			criminal.beaten_up()
	
	spawn_civ()
	spawn_crim()
	spawn_cop()

func spawn_civ():
	if civ_current > CIV_LIMIT:
		return

	var new_civ = Civ.instance()
	add_child(new_civ)
	assign_start_point(new_civ)
	assign_goal_civ_point(new_civ)
	
	civ_current += 1
	
	new_civ.connect("player_found", self, "_on_Civ_player_found")

func spawn_crim():
	if crim_current > CRIM_LIMIT or !crim_spawning:
		crim_spawning = false
		return
	
	var new_crim = Crim.instance()
	criminal_group.add_child(new_crim)
	assign_start_point(new_crim)
	assign_goal_crim_point(new_crim)
	
	crim_current += 1
	
	new_crim.connect("criminal_beaten", self, "_on_Crim_beaten_up")
	new_crim.connect("new_goal", self, "_on_Crim_new_goal")

func spawn_cop():
	if cop_current > COP_LIMIT:
		return
	
	var new_cop = Cop.instance()
	cop_group.add_child(new_cop)
	assign_start_point(new_cop)
	
	cop_current += 1
	
	new_cop.connect("ended_chase", self, "_on_Cop_ended_chase")
	new_cop.connect("player_caught", self, "_on_Cop_caught_player")
	new_cop.connect("new_goal_cop", self, "_on_Cop_new_goal")

func assign_start_point(npc):
	var node_number = cop_stations.get_child_count()
	var start_point = start_points.get_child(randi() % node_number)
	npc.position = start_point.position
	npc.START_POINT = start_point.position

func assign_goal_civ_point(npc):
	var node_number = civ_goals.get_child_count()
	var goal = civ_goals.get_child(randi() % node_number)
	npc.GOAL_POINT = goal.position

func assign_goal_crim_point(npc):
	var node_number = crime_spots.get_child_count()
	var rand = randi() % node_number
	
	if rand == closest_crime_spot():
		rand = (rand + 1) % node_number
	
	var goal = crime_spots.get_child(rand)
	npc.current_target = goal.position
 
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

func assign_goal_cop_point(npc):
	var node_number = cop_stations.get_child_count()
	var goal = cop_stations.get_child(randi() % node_number)
	npc.current_target = goal.position


func _on_Civ_player_found():
	if game_won:
		return
	
	if !cooldown.is_stopped():
		return
	
	player.set_being_chased(true)
	Soundplayer.play_sound(Soundplayer.CHASE)
	
	for cop in cop_group.get_children():
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
	assign_goal_crim_point(crim)

func _on_Cop_new_goal(cop):
	assign_goal_cop_point(cop)

func _on_Cop_caught_player():
	if game_won:
		return
	
	player.queue_free()
	Soundplayer.play_sound(Soundplayer.CAUGHT)
	
	game_over = true
	game_over_text.visible = true
	restart_text.visible = true
