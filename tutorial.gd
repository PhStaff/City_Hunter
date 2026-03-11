extends CutsceneDirector

signal tutorial_end

@onready var player = $Player

@onready var crowd = $Crowd
@onready var civ1 = $Crowd/Civ1
@onready var civ2 = $Crowd/Civ2
@onready var civ3 = $Crowd/Civ3

@onready var police = $Police
@onready var cop1 = $Police/Cop1
@onready var cop2 = $Police/Cop2
@onready var cop3 = $Police/Cop3
@onready var criminal = $Criminal

func _ready() -> void:
	super()
	
	#Start
	await cca("load_dialogue", ["GREETINGS"])
	await cca("zoom_camera", [Vector2(1.0, 1.0), Vector2(5.0, 5.0), 1.5])
	#await cca("wait", [60.0])
	
	crowd.visible = true
	criminal.visible = true
	police.visible = true
	
	#Being undetected by civs
	await cca("move_character", [player, 8 * Vector2(12.0, 0.0), 1.75])
	await cca("load_dialogue", ["BEING_UNDETECTED"])
	await cca("move_character", [crowd, 8 * Vector2(0.0, 25.0), 1.5])
	
	#Detecting criminals
	await cca("move_character", [criminal, 8 * Vector2(0.0, -9.0), 1.5])
	await cca("load_dialogue", ["DETECTING_CRIMINALS"])
	await cca("move_character", [criminal, 8 * Vector2(-12.0, 0.0), 1.75])
	
	#Following, masking and knocking out criminals
	player.masking()
	await cca("load_dialogue", ["MASKING_UP"])
	
	await cca("move_character", [player, 8 * Vector2(-11.0, 0.0), 1.75])
	
	await cca("load_dialogue", ["BEATING_CRIMINALS"])
	criminal.beaten_up()
	
	#Being spotted by civs while being masked
	await cca("move_character", [player, 8 * Vector2(11.0, 0.0), 1.75])
	await cca("move_character", [crowd, 8 * Vector2(0.0, -16.0), 1.5])
	
	#Alarm
	await cca("load_dialogue", ["SPOTTED_MASKED"])
	player.set_being_chased(true)
	cop1.set_chasing_player(true)
	cop2.set_chasing_player(true)
	cop3.set_chasing_player(true)
	Soundplayer.play_sound(Soundplayer.CHASE)
	
	await cca("move_character", [crowd, 8 * Vector2(0.0, -13.0), 0.5])
	
	#Being spotted by civs while being chased
	player.masking()
	await cca("move_character", [crowd, 8 * Vector2(0.0, 13.0), 1.0])
	
	#Alarm
	Soundplayer.play_sound(Soundplayer.CHASE)
	await cca("load_dialogue", ["SPOTTED_CHASED"])
	await cca("move_character", [crowd, 8 * Vector2(0.0, 13.0), 1.0])
	await cca("load_dialogue", ["HIDE"])
	
	#Being chased and hiding
	await cca("move_character", [player, 8 * Vector2(-12.0, 0.0), 1.0])
	await cca("move_character", [police, 8 * Vector2(0.0, -11.0), 1.0])
	
	#Being clear
	player.set_being_chased(false)
	cop1.set_chasing_player(false)
	cop2.set_chasing_player(false)
	cop3.set_chasing_player(false)
	
	await cca("load_dialogue", ["CLEAR"])
	await cca("move_character", [police, 8 * Vector2(0.0, 11.0), 2.5])
	
	crowd.visible = false
	police.visible = false
	
	#Ending
	await cca("zoom_camera", [Vector2(5.0, 5.0), Vector2(1.0, 1.0), 1.5])
	await cca("wait", [1.0])
	await cca("load_dialogue", ["GAME_START"])
	
	#End
	emit_signal("tutorial_end")
