extends Marker2D

signal push_dialogue(dialogue_id : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	var player : Player = Player.new_player(Player.DIRECTION.DOWN, Player.WEAPON.UNARMED)
	add_child(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
