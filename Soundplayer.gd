extends Node

const CITY = preload("res://_sound/city_sounds.mp3")

const BEATING = preload("res://_sound/punch.mp3")
const CHASE = preload("res://_sound/siren.mp3")
const CAUGHT = preload("res://_sound/taser.mp3")
#const ESCAPED = preload("res://_sound/escaped.wav")

#const MASK_UP = preload("res://_sound/mask_up.wav")
#const MASK_DOWN = preload("res://_sound/mask_down.wav")

#const TEST = preload("res://_sound/test.wav")

onready var audioPlayers: = $AudioPlayers

func play_sound(sound):
	for audioStreamPlayer in audioPlayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break
