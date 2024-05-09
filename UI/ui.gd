extends CanvasLayer

@onready var dialogueTextLabel := %DialogueText
signal push_dialogue(dialogue_index : int)

var json_dialogue: JSON
var dialogueData : Array

func _ready():
	json_dialogue = load("res://Resources/Dialogue/dialogue_master.tres")
	dialogueData = json_dialogue.data
	
	
func _process(delta):
	pass


func _on_push_dialogue(dialogue_index):
	var data = dialogueData[dialogue_index]
	dialogueTextLabel.text = data.dialogue
	print(dialogueTextLabel.text)
