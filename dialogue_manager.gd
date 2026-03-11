extends Node

signal dialogue_done

@onready var panel: = $CanvasLayer/Panel
@onready var text_label: = $CanvasLayer/Panel/Text_Label

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("player_space"):
		end_dialogue()

func show_dialogue(text: String):
	text_label.text = set_text(text)
	panel.visible = true

func set_text(text: String):
	if text == "GREETINGS":
		return "You are a vigilante and you are here to hunt down criminals!"
	elif text == "BEING_UNDETECTED":
		return "While being unmasked you can freely walk around the city. As long as you don't wear your mask, people won't notice you."
	elif text == "DETECTING_CRIMINALS":
		return "Criminals look like civilians until you are close enough to detect them."
	elif text == "MASKING_UP":
		return "You can beat up criminals after you put on your mask with 'Space'. Press 'E' for the actual beating."
	elif text == "BEATING_CRIMINALS":
		return "KAAPOW!"
	elif text == "SPOTTED_MASKED":
		return "When civilians find you while you are wearing your mask, they will call the cops on you!"
	elif text == "SPOTTED_CHASED":
		return "Even being unmasked, the civilians will call the cops on you while you are already chased."
	elif text == "HIDE":
		return "The cops are coming, hide!"
	elif text == "CLEAR":
		return "The cops checked the place you were last spotted and couldn't find you. You are clear now."
	elif text == "GAME_START":
		return "Find all the criminals and beat them up!"
	else:
		return "No text"

func end_dialogue():
	panel.visible = false
	emit_signal("dialogue_done")
