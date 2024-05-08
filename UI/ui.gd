extends CanvasLayer

@onready var dialogueTextLabel := %DialogueText
signal push_dialogue(dialogue_id : int)

func _ready():
	pass
	
func _process(delta):
	pass


func _on_push_dialogue(dialogue_id):
	print("dialogue_id: ",dialogue_id)
