class_name Main extends Node2D

enum INTERACT_OPTION {NONE, DIALOGUE, ITEM}

@onready var ui := %UI
@onready var objectCollision : Area2D = %ObjectCollision

signal update_interaction(can_interact : bool)
signal update_is_interacting(is_interacting: bool)

@export var interaction_dictionary : Array[InteractionDictionary] = []
var interaction : InteractionDictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_start_interact():
	ui.interact.emit(interaction.interaction_option, interaction.interaction_ids)
	await get_tree().create_timer(.01).timeout
	update_interaction.emit(true)


func _on_object_collision_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("player"):
		for this_interaction in interaction_dictionary:
			if this_interaction.collision_shape_index == body_shape_index:
				interaction = this_interaction
				break
		update_interaction.emit(true)

func _on_object_collision_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("player"):
		update_interaction.emit(false)
		interaction = null
		ui.interact.emit(INTERACT_OPTION.NONE, [-1])
