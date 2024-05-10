extends Resource
class_name InteractionDictionary

enum INTERACT_OPTION {NONE, DIALOGUE, ITEM}

@export var interaction_option : INTERACT_OPTION
@export var interaction_ids : Array[int]
@export var collision_shape_index : int

func _to_string():
	return str("interaction_option: ", interaction_option, " | interaction_ids: ", interaction_ids, " | collision_shape_index: ", collision_shape_index)
