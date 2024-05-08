extends CharacterBody2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var animationTree : AnimationTree = $AnimationTree
@onready var health_bar : ProgressBar = %HealthBar
@onready var rayCastFront: RayCast2D = %RayCastFront
@onready var rayCastLeft : RayCast2D = %RayCastLeft
@onready var rayCastRight : RayCast2D = %RayCastRight
@onready var bodyCollision : CollisionShape2D = %CollisionShape2D
@onready var detectionCollision : CollisionShape2D = %DetectionCollisionShape2D

enum DIRECTION {DOWN, UP, LEFT, RIGHT, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT}
enum ANIMATION {IDLE, WALK, ATTACK1, DEATH}
enum AI {IDLE, PATROL, CHASE, RETURNING, DEATH}
enum PATROL_TYPE {LOOP, LINEAR, NONE}

#1 = forward, 2 = backward
var linear_direction = 1 

@export var SPEED = 50
var patrol_speed : int = SPEED / 2

@export var patrol_type : PATROL_TYPE = PATROL_TYPE.LINEAR

var last_pos_x : float
var last_pos_y : float
var last_pos : Vector2
var last_progress_made : float
var init_pos : Vector2
var distance_from_init : int = 500

@onready var enemy_path = get_parent()

@export var direction_state = DIRECTION.DOWN
var animation_state = ANIMATION.IDLE
@export var ai_state = AI.IDLE

var player : Object

@export var texArray : Array[Texture2D] #idle, walk, attack

var health : int = 3
var can_attack : bool = true

var knockback : Vector2 = Vector2.ZERO
var knockback_strength : float = 10.0
var can_move : bool = true

func _ready():
	last_pos_x = enemy_path.position.x
	last_pos_y = enemy_path.position.y
	last_pos = enemy_path.position
	last_progress_made = 0
	init_pos = global_position
	var path2D : Path2D = enemy_path.get_parent()
	#for i in range(path2D.curve.point_count):
		#print(path2D.curve.get_point_position(i))
	#print("ini_pos: ", init_pos)
	#print("enemy_path: ",enemy_path.get_class() == "PathFollow2D")

func _physics_process(delta):
	if ai_state == AI.DEATH:
		updateSprites()
		updateAnimations()
		return
		
	#elif ai_state != AI.RETURNING and (init_pos.x - global_position.x > distance_from_init or init_pos.x - global_position.x < -distance_from_init or init_pos.y - global_position.y > distance_from_init or init_pos.y - global_position.y < -distance_from_init):
	elif ai_state != AI.RETURNING and abs(global_position.distance_to(init_pos)) > distance_from_init:
		#print("position diff: ", init_pos - global_position)
		#print("true")
		ai_state = AI.RETURNING
		animation_state = ANIMATION.WALK
		updateDirectionState()
		
	elif ai_state == AI.RETURNING:
		bodyCollision.set_deferred("disabled", true)
		detectionCollision.set_deferred("disabled", true)
		updateDirectionState()
		#var direction = (init_pos - global_position).normalized()
		var direction = global_position.direction_to(init_pos)
		if direction:
			velocity = direction * SPEED*3 * delta
		else:
			velocity = Vector2.ZERO
		move_and_collide(velocity)
		#if init_pos.x - global_position.x < .1 and init_pos.x - global_position.x > -.1:
		if abs(global_position.distance_to(init_pos)) < 2:
			ai_state = AI.PATROL
			position = Vector2.ZERO
			enemy_path.progress = 0
			enemy_path.progress_ratio = 0
			bodyCollision.set_deferred("disabled", false)
			detectionCollision.set_deferred("disabled", false)
			
	elif ai_state == AI.CHASE:
		var distance_to_player = player.global_position - global_position
		if !can_move || !can_attack:
			distance_to_player = Vector2.ZERO
		else:
			updateDirectionState()
		if (abs(distance_to_player.x) > 50 || abs(distance_to_player.y) > 62) && animation_state != ANIMATION.ATTACK1:
			animation_state = ANIMATION.WALK
			velocity = distance_to_player * SPEED * delta + knockback
			move_and_slide()
		elif can_attack:
			animation_state = ANIMATION.ATTACK1
			velocity = Vector2.ZERO + knockback
			move_and_slide()
		else:
			animation_state = ANIMATION.IDLE
			velocity = Vector2.ZERO + knockback
			move_and_slide()
		knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	elif ai_state == AI.PATROL:
		if enemy_path.get_class() == "PathFollow2D":
			patrol(delta)
	updateSprites()
	updateAnimations()

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
	
func updateDirectionState():
	var pos_x
	var pos_y
	
	if ai_state == AI.CHASE:
		pos_x = player.global_position.x
		pos_y = player.global_position.y
	elif ai_state == AI.RETURNING:
		pos_x = init_pos.x
		pos_y = init_pos.y
	elif ai_state == AI.PATROL:
		pos_x = last_pos.x
		pos_y = last_pos.y
	else:
		return
		#print("pos_x: ", pos_x)
		#print("pos_y: ", pos_y)
	var enemy_x = global_position.x
	var enemy_y = global_position.y
	#print("pos: ", Vector2(enemy_x - pos_x, enemy_y - pos_y))
	var rotation_step = 25
	
	#if Input.is_action_just_pressed("attack_1"):
		#print("player: ", player.global_position)
		#print("enemy: ", global_position)
		
	var r_down = Vector2(0,65)
	var r_down_right = Vector2(50,36)
	var r_down_left = Vector2(-50,36)
	var r_up = Vector2(0,-40)
	var r_up_left = Vector2(-50,-33)
	var r_up_right = Vector2(50,-33)
	var r_right = Vector2(40,0)
	var r_left = Vector2(-40,0)
	
	if (enemy_x - pos_x) < rotation_step && (enemy_x - pos_x) > -rotation_step && (enemy_y - pos_y) < 0:
		direction_state = DIRECTION.DOWN
		rayCastFront.target_position = r_down
		rayCastLeft.target_position = Vector2(r_down_right.x/6,r_down_right.y*1.5)
		rayCastRight.target_position = Vector2(r_down_left.x/6,r_down_left.y*1.5)
	elif (enemy_x - pos_x) < rotation_step && (enemy_x - pos_x) > -rotation_step && (enemy_y - pos_y) > 0:
		direction_state = DIRECTION.UP
		rayCastFront.target_position = r_up
		rayCastLeft.target_position = Vector2(r_up_left.x/6,r_up_left.y*1.5)
		rayCastRight.target_position = Vector2(r_up_right.x/6,r_up_right.y*1.5)
	elif (enemy_x - pos_x) < 0 && (enemy_y - pos_y) > -rotation_step && (enemy_y - pos_y) < rotation_step:
		direction_state = DIRECTION.RIGHT
		rayCastFront.target_position = r_right
		rayCastLeft.target_position = Vector2(r_up_right.x,r_up_right.y/1.5)
		rayCastRight.target_position = Vector2(r_down_right.x,r_down_right.y/1.5)
	elif (enemy_x - pos_x) > 0 && (enemy_y - pos_y) > -rotation_step && (enemy_y - pos_y) < rotation_step:
		direction_state = DIRECTION.LEFT
		rayCastFront.target_position = r_left
		rayCastLeft.target_position = Vector2(r_down_left.x,r_down_left.y/1.5)
		rayCastRight.target_position = Vector2(r_up_left.x,r_up_left.y/1.5)
	elif (enemy_x - pos_x) > rotation_step && (enemy_y - pos_y) < rotation_step:
		direction_state = DIRECTION.DOWN_LEFT
		rayCastFront.target_position = r_down_left
		rayCastLeft.target_position = Vector2(-40,r_down.y)
		rayCastRight.target_position = Vector2(r_left.x,15)
	elif (enemy_x - pos_x) < -rotation_step && (enemy_y - pos_y) < rotation_step:
		direction_state = DIRECTION.DOWN_RIGHT
		rayCastFront.target_position = r_down_right
		rayCastLeft.target_position = Vector2(r_right.x,15)
		rayCastRight.target_position = Vector2(40,r_down.y)
	elif (enemy_x - pos_x) > rotation_step && (enemy_y - pos_y) > -rotation_step:
		direction_state = DIRECTION.UP_LEFT
		rayCastFront.target_position = r_up_left
		rayCastLeft.target_position = Vector2(r_left.x,-15)
		rayCastRight.target_position = Vector2(-40,r_up.y)
	elif (enemy_x - pos_x) < -rotation_step && (enemy_y - pos_y) > -rotation_step:
		direction_state = DIRECTION.UP_RIGHT
		rayCastFront.target_position = r_up_right
		rayCastLeft.target_position = Vector2(40,r_up.y)
		rayCastRight.target_position = Vector2(r_right.x,-15)
	
func updateSprites():
	if animation_state == ANIMATION.IDLE:
		sprite.hframes = 24
		sprite.vframes = 1
		sprite.set_texture(texArray[ANIMATION.IDLE])
	elif animation_state == ANIMATION.WALK:
		sprite.hframes = 24
		sprite.vframes = 3
		sprite.set_texture(texArray[ANIMATION.WALK])
	elif animation_state == ANIMATION.ATTACK1:
		sprite.hframes = 24
		sprite.vframes = 1
		sprite.set_texture(texArray[ANIMATION.ATTACK1])
	elif animation_state == ANIMATION.DEATH:
		sprite.hframes = 24
		sprite.vframes = 1
		sprite.set_texture(texArray[ANIMATION.DEATH])

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
		setAnimation("parameters/attack/BlendSpace2D/blend_position")
	elif animation_state == ANIMATION.IDLE:
		setAnimation("parameters/idle/BlendSpace2D/blend_position")
	elif animation_state == ANIMATION.WALK:
		setAnimation("parameters/walk/BlendSpace2D/blend_position")
	elif animation_state == ANIMATION.DEATH:
		setAnimation("parameters/death/BlendSpace2D/blend_position")
	animationTree.set("parameters/conditions/attack", animation_state == ANIMATION.ATTACK1)
	animationTree.set("parameters/conditions/death", animation_state == ANIMATION.DEATH)
	animationTree.set("parameters/conditions/idle", animation_state == ANIMATION.IDLE)
	animationTree.set("parameters/conditions/walk", animation_state == ANIMATION.WALK)

func take_damage(damage : int, dir_state : DIRECTION):
	health -= damage
	health_bar.value = health
	knockback = getKnockbackFromDirectionState(dir_state) * knockback_strength
	if health <= 0:
		ai_state = AI.DEATH
		bodyCollision.set_deferred("disabled", true)
		animation_state = ANIMATION.DEATH
		health_bar.hide()
		#changing the z_index allows the enemy to be below the player at all times -1 = Level-Floor
		z_index = -1
		await get_tree().create_timer(5).timeout
		queue_free()
		return
	can_move = false
	# random amount of stagger time between 0 and 3 seconds
	await get_tree().create_timer(randi() % 3).timeout
	can_move = true

func _on_detection_area_body_entered(body):
	if body.is_in_group("player") && ai_state != AI.DEATH:
		ai_state = AI.CHASE
		player = body
		animation_state = ANIMATION.WALK


func _on_detection_area_body_exited(body):
	if body.is_in_group("player") && ai_state != AI.DEATH:
		ai_state = AI.RETURNING
		player = null
		animation_state = ANIMATION.WALK


func _on_animation_tree_animation_finished(anim_name):
	if (anim_name == "attack_south" || anim_name == "attack_west" || anim_name == "attack_east" || anim_name == "attack_north"
	|| anim_name == "attack_south_west" || anim_name == "attack_north_west" || anim_name == "attack_south_east" || anim_name == "attack_north_east"):
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
		can_move = true
		can_attack = false
		if get_tree() != null:
			await get_tree().create_timer(3).timeout
			can_attack = true


func _on_animation_tree_animation_started(anim_name):
	if (anim_name == "attack_south" || anim_name == "attack_west" || anim_name == "attack_east" || anim_name == "attack_north"
	|| anim_name == "attack_south_west" || anim_name == "attack_north_west" || anim_name == "attack_south_east" || anim_name == "attack_north_east"):
		can_move = false

func patrol(delta):
	if enemy_path.progress_ratio == 0 or enemy_path.progress_ratio == 1 or last_progress_made > enemy_path.progress:
		animation_state = ANIMATION.IDLE
		ai_state = AI.IDLE
		updateDirectionState()
		await get_tree().create_timer(3).timeout
		if ai_state == AI.IDLE:
			ai_state = AI.PATROL
	else:
		animation_state = ANIMATION.WALK
	
	if patrol_type == PATROL_TYPE.LOOP:
		last_pos_x = enemy_path.position.x
		last_pos_y = enemy_path.position.y
		last_pos = enemy_path.get_parent().curve.get_closest_point(global_position)
		last_progress_made = enemy_path.progress
		#print("last_pos_x: ", last_pos_x)
		enemy_path.progress += patrol_speed * delta
		#print("enemy pos: ", enemy_path.position.x)
		if rotation_degrees != 0:
			#rotation_degrees = lerp(rotation_degrees, 0.0, 0.2)
			pass
	elif patrol_type == PATROL_TYPE.LINEAR:
		if linear_direction == 1:
			if enemy_path.progress_ratio > .99:
				enemy_path.progress_ratio = 1
				await get_tree().create_timer(0.3).timeout
				#rotation_degrees = lerp(rotation_degrees, 180.0, 0.1)
				#await get_tree().create_timer(1).timeout
				linear_direction = 0
			else:
				last_pos_x = enemy_path.position.x
				last_pos_y = enemy_path.position.y
				last_pos = enemy_path.get_parent().curve.sample(0, 1)
				enemy_path.progress += patrol_speed * delta
				updateDirectionState()
				#print("point: ", enemy_path.get_parent().get_curve().get_closest_offset(global_position))
				#print("closest point: ", enemy_path.get_parent().curve.get_closest_point(global_position))
				#print("sample: ", last_pos)
		else:
			if enemy_path.progress_ratio < .01:
				enemy_path.progress_ratio = 0
				await get_tree().create_timer(0.3).timeout
				#rotation_degrees = lerp(rotation_degrees, 0.0, 0.1)
				#await get_tree().create_timer(1).timeout
				linear_direction = 1
			else:
				last_pos_x = enemy_path.position.x
				last_pos_y = enemy_path.position.y
				last_pos = enemy_path.get_parent().curve.sample(0, 0)
				enemy_path.progress -= patrol_speed * delta
				updateDirectionState()
				#print("point: ", enemy_path.get_parent().get_curve().get_closest_offset(global_position))
				#print("sample: ", last_pos)
