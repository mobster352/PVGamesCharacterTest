extends Resource
class_name InteractionDictionary

enum INTERACT_OPTION {NONE, DIALOGUE, ITEM}

@export var interaction_option : INTERACT_OPTION
@export var interaction_ids : Array[int]
@export var path_to_collider : String

func _init(p_interaction_option, p_interaction_ids, p_path_to_collider):
	interaction_option = p_interaction_option
	interaction_ids = p_interaction_ids
	path_to_collider = p_path_to_collider
