class_name Main extends Node2D

@onready var ui := %UI
@onready var objectCollision : Area2D = %ObjectCollision

signal update_interaction(can_interact : bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_start_push_dialogue(dialogue_index):
	ui.push_dialogue.emit(dialogue_index)


func _on_object_collision_body_entered(body):
	if body.is_in_group("player"):
		update_interaction.emit(true)


func _on_object_collision_body_exited(body):
	if body.is_in_group("player"):
		update_interaction.emit(false)
