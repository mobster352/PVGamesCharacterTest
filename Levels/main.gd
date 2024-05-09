class_name Main extends Node2D

enum INTERACT_OPTION {NONE, DIALOGUE, ITEM}

var interact_option := INTERACT_OPTION.NONE

@onready var ui := %UI
@onready var objectCollision : Area2D = %ObjectCollision

signal update_interaction(can_interact : bool)
signal update_is_interacting(is_interacting: bool)

var dialogueIdx : Array

@export var interaction_dictionary : Array[InteractionDictionary]



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_object_collision_body_entered(body):
	if body.is_in_group("player"):
		update_interaction.emit(true)
		interact_option = INTERACT_OPTION.DIALOGUE
		dialogueIdx = [0]


func _on_object_collision_body_exited(body):
	if body.is_in_group("player"):
		update_interaction.emit(false)
		interact_option = INTERACT_OPTION.NONE
		dialogueIdx = Array()
		ui.interact.emit(interact_option, [-1])


func _on_player_start_interact():
	ui.interact.emit(interact_option, dialogueIdx)
	await get_tree().create_timer(.01).timeout
	update_interaction.emit(true)
