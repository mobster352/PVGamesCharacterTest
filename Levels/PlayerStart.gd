extends Marker2D

var player : Player

signal push_dialogue(dialogue_index : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.new_player(Player.DIRECTION.DOWN, Player.WEAPON.UNARMED)
	add_child(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_level_update_interaction(can_interact):
	player.set_can_interact(can_interact)
