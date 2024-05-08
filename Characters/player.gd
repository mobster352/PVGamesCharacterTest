class_name Player
extends CharacterBody2D

@onready var characterSprite : Sprite2D = %Character
@onready var rayCastFront : RayCast2D = %RayCastFront
@onready var rayCastLeft : RayCast2D = %RayCastLeft
@onready var rayCastRight : RayCast2D = %RayCastRight
@onready var animationTree : AnimationTree = %AnimationTree
@onready var healthBar : ProgressBar = %HealthBar
@onready var canvasLayer : CanvasLayer = %CanvasLayer

enum DIRECTION {DOWN, UP, LEFT, RIGHT, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT}
enum ANIMATION {IDLE, WALK, ATTACK1}
enum WEAPON {UNARMED, SWORD, SWORD_BACK}

var direction_state = DIRECTION.DOWN
var animation_state = ANIMATION.IDLE
var weapon_state : WEAPON = WEAPON.UNARMED

const SPEED = 250.0

var characterTexArray : Array

var is_attacking : bool = false

var health : int = 3

var knockback : Vector2 = Vector2.ZERO
var knockback_strength : float = 10.0
var can_move : bool = true
var can_attack : bool

static func new_player(direction : DIRECTION, weapon : WEAPON):
	var my_scene : PackedScene = load("res://Characters/player.tscn")
	var new_player : Player = my_scene.instantiate()
	new_player.direction_state = direction
	new_player.weapon_state = weapon
	return new_player

func setWeapon(weapon : WEAPON):
	weapon_state = weapon
	characterTexArray.clear()
	if weapon == WEAPON.UNARMED:
		characterTexArray.append(load("res://PVGames Assets/Male_Footman/male_footman_idle_unarmed.png"))
		characterTexArray.append(load("res://PVGames Assets/Male_Footman/male_footman_walking_unarmed.png"))
		can_attack = false
	elif weapon == WEAPON.SWORD:
		characterTexArray.append(load("res://PVGames Assets/Male_Footman/male_footman_idle_sword.png"))
		characterTexArray.append(load("res://PVGames Assets/Male_Footman/male_footman_walking_sword.png"))
		characterTexArray.append(load("res://PVGames Assets/Male_Footman/male_footman_attacking_sword.png"))
		can_attack = true
	elif weapon == WEAPON.SWORD_BACK:
		characterTexArray.append(load("res://PVGames Assets/Male_Footman/male_footman_idle_sword_back.png"))
		characterTexArray.append(load("res://PVGames Assets/Male_Footman/male_footman_walking_sword_back.png"))
		can_attack = false
	else:
		characterTexArray.append(load("res://PVGames Assets/Male_Footman/male_footman_idle_unarmed.png"))
		characterTexArray.append(load("res://PVGames Assets/Male_Footman/male_footman_walking_unarmed.png"))
		can_attack = false

func setAnimation(blend_position_path: String):
	if direction_state == DIRECTION.DOWN:
		animationTree.set(blend_position_path, Vector2(0, 1.1))
	elif direction_state == DIRECTION.UP:
		animationTree.set(blend_position_path, Vector2(0, -1.1))
	elif direction_state == DIRECTION.RIGHT:
		animationTree.set(blend_position_path, Vector2(1, 0))
	elif direction_state == DIRECTION.LEFT:
		animationTree.set(blend_position_path, Vector2(-1, 0))
	elif direction_state == DIRECTION.UP_LEFT:
		animationTree.set(blend_position_path, Vector2(-1, -1.1))
	elif direction_state == DIRECTION.UP_RIGHT:
		animationTree.set(blend_position_path, Vector2(1, -1.1))
	elif direction_state == DIRECTION.DOWN_LEFT:
		animationTree.set(blend_position_path, Vector2(-1, 1.1))
	elif direction_state == DIRECTION.DOWN_RIGHT:
		animationTree.set(blend_position_path, Vector2(1, 1.1))

func updateAnimations():
	if animation_state == ANIMATION.ATTACK1:
		setAnimation("parameters/attack1/BlendSpace2D/blend_position")
	elif animation_state == ANIMATION.IDLE:
		setAnimation("parameters/idle/idle_blendtree/BlendSpace2D/blend_position")
	elif animation_state == ANIMATION.WALK:
		setAnimation("parameters/walking/BlendSpace2D/blend_position")

func updateSprites():
	if animation_state == ANIMATION.IDLE:
		characterSprite.hframes = 24
		characterSprite.vframes = 1
		characterSprite.set_texture(characterTexArray[ANIMATION.IDLE])
	elif animation_state == ANIMATION.WALK:
		characterSprite.hframes = 24
		characterSprite.vframes = 3
		characterSprite.set_texture(characterTexArray[ANIMATION.WALK])
	elif animation_state == ANIMATION.ATTACK1:
		characterSprite.hframes = 24
		characterSprite.vframes = 1
		characterSprite.set_texture(characterTexArray[ANIMATION.ATTACK1])

func updateDirectionState(direction : Vector2):
	var r_down = Vector2(0,65)
	var r_down_right = Vector2(50,36)
	var r_down_left = Vector2(-50,36)
	var r_up = Vector2(0,-40)
	var r_up_left = Vector2(-50,-33)
	var r_up_right = Vector2(50,-33)
	var r_right = Vector2(40,0)
	var r_left = Vector2(-40,0)
	
	if direction.x == 0 && direction.y > 0:
		direction_state = DIRECTION.DOWN
		rayCastFront.target_position = r_down
		rayCastLeft.target_position = Vector2(r_down_right.x/6,r_down_right.y*1.5)
		rayCastRight.target_position = Vector2(r_down_left.x/6,r_down_left.y*1.5)
	elif direction.x == 0 && direction.y < 0:
		direction_state = DIRECTION.UP
		rayCastFront.target_position = r_up
		rayCastLeft.target_position = Vector2(r_up_left.x/6,r_up_left.y*1.5)
		rayCastRight.target_position = Vector2(r_up_right.x/6,r_up_right.y*1.5)
	elif direction.x > 0 && direction.y == 0:
		direction_state = DIRECTION.RIGHT
		rayCastFront.target_position = r_right
		rayCastLeft.target_position = Vector2(r_up_right.x,r_up_right.y/1.5)
		rayCastRight.target_position = Vector2(r_down_right.x,r_down_right.y/1.5)
	elif direction.x < 0 && direction.y == 0:
		direction_state = DIRECTION.LEFT
		rayCastFront.target_position = r_left
		rayCastLeft.target_position = Vector2(r_down_left.x,r_down_left.y/1.5)
		rayCastRight.target_position = Vector2(r_up_left.x,r_up_left.y/1.5)
	elif direction.x < 0 && direction.y < 0:
		direction_state = DIRECTION.UP_LEFT
		rayCastFront.target_position = r_up_left
		rayCastLeft.target_position = Vector2(r_left.x,-15)
		rayCastRight.target_position = Vector2(-40,r_up.y)
	elif direction.x > 0 && direction.y < 0: 
		direction_state = DIRECTION.UP_RIGHT
		rayCastFront.target_position = r_up_right
		rayCastLeft.target_position = Vector2(40,r_up.y)
		rayCastRight.target_position = Vector2(r_right.x,-15)
	elif direction.x < 0 && direction.y > 0:
		direction_state = DIRECTION.DOWN_LEFT
		rayCastFront.target_position = r_down_left
		rayCastLeft.target_position = Vector2(-40,r_down.y)
		rayCastRight.target_position = Vector2(r_left.x,15)
	elif direction.x > 0 && direction.y > 0: 
		direction_state = DIRECTION.DOWN_RIGHT
		rayCastFront.target_position = r_down_right
		rayCastLeft.target_position = Vector2(r_right.x,15)
		rayCastRight.target_position = Vector2(40,r_down.y)

func _ready():
	canvasLayer.show()
	setWeapon(weapon_state)

func _process(delta):
	if weapon_state == WEAPON.SWORD_BACK and Input.is_action_just_pressed("draw_weapon"):
		setWeapon(WEAPON.SWORD)
	elif weapon_state == WEAPON.SWORD and Input.is_action_just_pressed("draw_weapon"):
		setWeapon(WEAPON.SWORD_BACK)
		
	if Input.is_action_just_pressed("attack_1"):
		get_parent().push_dialogue.emit(1)
	
func updateAnimationTree(anim_state: ANIMATION, velo: Vector2):
	velocity = velo
			
	animation_state = anim_state
		
	updateSprites()
	
	if anim_state == ANIMATION.ATTACK1:
		animationTree.set("parameters/conditions/attack", true)
	else:	
		animationTree.set("parameters/conditions/idle", anim_state == ANIMATION.IDLE)
		animationTree.set("parameters/conditions/walk", anim_state == ANIMATION.WALK)

func _physics_process(delta):
	if is_attacking:
		return
	
	var direction: Vector2 = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	
	if !can_move:
			direction = Vector2.ZERO
			
	updateDirectionState(direction)
	
	var attack1 : bool = Input.is_action_just_pressed("attack_1")
	
	if attack1 and can_attack:
		is_attacking = true
		updateAnimationTree(ANIMATION.ATTACK1, Vector2.ZERO)
		
		if rayCastFront.is_colliding():
			var hit = rayCastFront.get_collider()
			#print("hit: ", hit.name)
			if hit.has_method("take_damage"):
				hit.take_damage(1, direction_state)
		elif rayCastLeft.is_colliding():
			var hit = rayCastLeft.get_collider()
			#print("hit: ", hit.name)
			if hit.has_method("take_damage"):
				hit.take_damage(1, direction_state)
		elif rayCastRight.is_colliding():
			var hit = rayCastRight.get_collider()
			#print("hit: ", hit.name)
			if hit.has_method("take_damage"):
				hit.take_damage(1, direction_state)
	else:
		if direction:
			updateAnimationTree(ANIMATION.WALK, direction.normalized() * SPEED + knockback)
		else:
			updateAnimationTree(ANIMATION.IDLE, Vector2.ZERO + knockback)
		
	updateAnimations()
	
	move_and_slide()
	
	knockback = lerp(knockback, Vector2.ZERO, 0.1)


func _on_animation_tree_animation_finished(anim_name):
	if (anim_name == "attack_south" || anim_name == "attack_west" || anim_name == "attack_east" || anim_name == "attack_north"
	|| anim_name == "attack_south_west" || anim_name == "attack_north_west" || anim_name == "attack_south_east" || anim_name == "attack_north_east"):
		is_attacking = false
		animationTree.set("parameters/conditions/attack", false)

func take_damage(damage : int, dir_state : DIRECTION):
	health -= damage
	healthBar.value = health
	knockback = getKnockbackFromDirectionState(dir_state) * knockback_strength
	if health <= 0:
		print("player died")
		get_tree().reload_current_scene()
		return
		#get_tree().quit()
	can_move = false
	await get_tree().create_timer(.5).timeout
	can_move = true

func getKnockbackFromDirectionState(dir_state : DIRECTION):
	if dir_state == DIRECTION.DOWN:
		return Vector2(0, 25)
	elif dir_state == DIRECTION.LEFT:
		return Vector2(-25, 0)
	elif dir_state == DIRECTION.RIGHT:
		return Vector2(25, 0)
	elif dir_state == DIRECTION.UP:
		return Vector2(0, -25)
	elif dir_state == DIRECTION.DOWN_LEFT:
		return Vector2(-20, 20)
	elif dir_state == DIRECTION.UP_LEFT:
		return Vector2(-20, -20)
	elif dir_state == DIRECTION.DOWN_RIGHT:
		return Vector2(20, 20)
	elif dir_state == DIRECTION.UP_RIGHT:
		return Vector2(20, -20)
		
