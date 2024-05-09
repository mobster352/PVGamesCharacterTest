extends CanvasLayer

enum OPTION {NONE, END, NEXT, SELECT}
enum INTERACT_OPTION {NONE, DIALOGUE, ITEM}

var dialogue_option : OPTION

@onready var dialogueControl := %Control
@onready var dialogueTextLabel := %DialogueText
@onready var dialogueTextureRect := %TextureRect

signal interact(interact_option : INTERACT_OPTION)

var json_dialogue: JSON
var dialogueDataArray : Array
var thisDialogueDataArray : Array
var current_dialogue : int

func _ready():
	json_dialogue = load("res://Resources/Dialogue/dialogue_master.tres")
	dialogueDataArray = json_dialogue.data
	dialogue_option = OPTION.NONE
	dialogueControl.hide()
	thisDialogueDataArray = Array()
	current_dialogue = 0
	
func _process(delta):
	pass

func end_dialogue():
	dialogue_option = OPTION.END
	dialogueControl.hide()
	thisDialogueDataArray.clear()
	current_dialogue = 0
	get_parent().update_is_interacting.emit(false)
	
func push_dialogue(idx : Array):
	dialogueTextLabel.clear()
	if current_dialogue >= idx.size():
		end_dialogue()
		return
	if current_dialogue == 0:
		dialogueControl.show()
	var data = thisDialogueDataArray[current_dialogue]
	if data.style == "Italics":
		dialogueTextLabel.push_italics()
	dialogueTextLabel.add_text(data.dialogue)
	if data.portrait:
		dialogueTextureRect.texture = load(data.portrait)
	current_dialogue += 1

func get_json_object_by_ids(ids : Array):
	for i in ids:
		thisDialogueDataArray.push_back(dialogueDataArray[i])

func _on_interact(interact_option : INTERACT_OPTION, idx : Array):
	if interact_option == INTERACT_OPTION.NONE:
		end_dialogue()
		return
	if interact_option == INTERACT_OPTION.DIALOGUE:
		if thisDialogueDataArray.is_empty():
			get_json_object_by_ids(idx)
			get_parent().update_is_interacting.emit(true)
		push_dialogue(idx)
