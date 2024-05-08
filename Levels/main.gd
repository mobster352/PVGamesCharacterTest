class_name Main extends Node2D

@onready var ui := %UI

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_start_push_dialogue(dialogue_id):
	ui.push_dialogue.emit(dialogue_id)
