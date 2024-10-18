extends KinematicBody2D

########## SIGNALS ##########



######### CONSTANTS #########

# Assume each tile (16 pixels) represents 1 meter
const TILE_SIZE_IN_METERS = 1.0 / 32.0

# JUMP CONSTANTS #
const JUMP_FORCE = -300.0
const JUMP_DELAY_TIME: float = 0.175
const WALLJUMPFORCE: float = 200.0
########### ENUMS ###########

# PLAYERSTATE ENUM #
enum PlayerState {
	IDLE,
	RUN,
	WALL_SLIDE,
	ATTACK,
	JUMP,
	FALL,
	DEAD
}

######### VARIABLES #########

# MOVEMENT VARS #
var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var velo_reset : bool = false
var movement_disabled : bool = false

# PLAYERSTATE VARS #
var playerState = PlayerState.IDLE
var timeSinceLastGrounded: float = 0.0
var attacking: bool = false

# TIMER VARS #
var timer = Timer.new()
var timer_active: bool = false
var knockback_time = 0.2
var wall_time = 0.1

# KNOCKBACK VARS #
var knockback: bool = false
var knockback_strength = 800
var knockback_force = 0
var knockback_direction = Vector2.ZERO

# JUMP VARS #
var wallJump = 600
var isJumping: bool = false
var isWallJumping : bool = false
var double_jump_enabled: bool = false
var can_double_jump: bool = true
const MAX_DOUBLE_JUMPS: int = 2
var double_jumps_used: int = 0
var wallJumpDir = Vector2.ZERO

# POSITION VARS #
var collision_position
var lastPortal = 0
var previous_position: Vector2

# LOAD VARS #
var hitAnim = load("res://effects/hitAnims/hitEffect.tscn")
var splashAudio = load("res://resources/sfx/splash/Splashplayer.tscn")
var hitAudioPlayer = load("res://resources/sfx/hit/Attackplayer.tscn")
const BLOOD = preload("res://scenes/effects/blood_particles.tscn")
const STATISTICS = preload("res://scenes/ui/stats/game_over_stats.tscn")

###### EXPORT VARIABLES ######

# MOVEMENT VARS #
export var speed = 105

# JUMP VARS #
export var jump_height: float
export var jump_time_to_peak: float
export var jump_time_to_descent: float

##### ONREADY VARIABLES #####

# JUMP VARS #
onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# NODE REFS #
onready var player_sprite = get_node("astronaut")
onready var footstep_audio = get_node("Audio/Footsteps")
onready var hit_anim_player = get_node("hitAnim")

########### READY ###########

func _ready():
	if material:
		material = material.duplicate()
	$player_cam.limit_left = -15
	$player_cam.limit_top = -10
	$player_cam.limit_right = 912 # 1140
	$player_cam.limit_bottom = 780#975
	
	
	update_player_state()
	update_player_skin()
	updateParticles()
	$CanvasLayer.show()
	$light_pulse.play("light_pulse")
	#$particles.hide()
	previous_position = position
	add_child(timer)
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_attack_timer")
	
###### PHYSICS_PROCESS #######

func _physics_process(delta: float) -> void:
	$playerstate.text = player_state_to_string(playerState)
	if !Global.pause:
		if Global.player_health <= 0:
			velocity.x = 0
		if knockback:
			if velo_reset:
				velocity = Vector2(0,0)
				velo_reset = false
			knockback_time -= delta
			knockback_direction = knockback_direction.move_toward(Vector2.ZERO, (knockback_force/1.3) * delta)
			move_and_slide(knockback_direction)
			
			if knockback_time <= 0:
				knockback_time = 0.2
				knockback = false
				movement_disabled = false
				
		if isWallJumping:
			if next_to_left_wall():
				wallJumpDir = Vector2(WALLJUMPFORCE, 0)
			if next_to_right_wall():
				wallJumpDir = Vector2(-WALLJUMPFORCE, 0)
			wall_time -= delta
			wallJumpDir = wallJumpDir.move_toward(Vector2.ZERO, wallJump * delta)
			move_and_slide(wallJumpDir)
			
			if wall_time <= 0:
				wall_time = 0.05
				isWallJumping = false
				
		if is_on_floor() or nextToWall():
			timeSinceLastGrounded = 0.0
			isJumping = false
			double_jumps_used = 0
			can_double_jump = double_jump_enabled
		else:
			timeSinceLastGrounded += delta

		if Input.is_action_just_pressed("jump"):
			jump(self)

		if playerState == PlayerState.IDLE or playerState == PlayerState.ATTACK:
			$particles.get_child(0).emitting = false
		else:
			$particles.get_child(0).emitting = is_on_floor() or nextToWall()
			
		if Input.is_action_just_pressed("jump") && Global.player_health > 0:
			if is_on_floor():
				jump(self)
			if nextToWall() && !is_on_floor():
				isWallJumping = true
			elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
				if next_to_right_wall() and !is_on_floor():
					jump(self)
					isJumping = true
					isWallJumping = true
				if next_to_left_wall() and !is_on_floor():
					jump(self)
					isJumping = true
					isWallJumping = true
						
		if nextToWall() and velocity.y > 0 and !is_on_floor():
			velocity.y = get_gravity() * 0.035
					
#		if Input.is_action_just_pressed("attack") and playerState != PlayerState.ATTACK:
#			$enemy_hitbox/attackingcollision.disabled = false
#			timer_active = true
#			timer.start($player_animations.get_animation("attack_1").length)
			
			
#		elif !timer_active:
#			$enemy_hitbox/attackingcollision.disabled = true
		
		if next_to_right_wall() && velocity.y != 0:
			player_sprite.scale.x = -1
		if next_to_left_wall() && velocity.y != 0:
			player_sprite.scale.x = 1

	velocity.y += get_gravity() * delta
	if Global.player_health > 0 and !knockback and !isWallJumping:
		velocity.x = get_input_velocity() * speed
	velocity = move_and_slide(velocity, Vector2.UP)

	
# warning-ignore:unused_argument
func _process(delta):
	double_jump_enabled = Global.modificators.has("double_jump")
	update_player_state()
	if !Global.show_player_state:
		$playerstate.hide()
	else:
		$playerstate.show()
		
	# Calculate the distance between the current position and the previous position in pixels
	var current_position = position
	var distance_moved_in_pixels = previous_position.distance_to(current_position)

	# Convert the distance from pixels to meters
	var distance_moved_in_meters = distance_moved_in_pixels * TILE_SIZE_IN_METERS

	# Update the total distance traveled in meters
	Global.total_distance_traveled += distance_moved_in_meters

	# Update the previous position for the next frame
	previous_position = current_position


	#print(str("FPS:",(Engine.get_frames_per_second())))
		
#	if Input.is_action_just_pressed("ui_accept"):
#		var dynaScene = load("res://objects/items/dynamite/dyna.tscn")
#		var dynaSceneInstance = dynaScene.instance()
#		dynaSceneInstance.global_position = global_position
#		get_tree().current_scene.add_child(dynaSceneInstance)
		
# warning-ignore:unused_argument
#func _input(event: InputEvent) -> void:
#	if Input.is_action_just_pressed("mb_right"):
#		update_player_skin()
#		updateParticles()

func get_input_velocity() -> float:
	var horizontal := 0.0
	if !movement_disabled:
		if Input.is_action_pressed("move_left"):
			horizontal -= 1.0#
			if !nextToWall():
				player_sprite.scale.x = -1
			$Player_collision.position.x = -1
			$enemy_hitbox/attackingcollision.position.x = -5
			$gem_raycasts/GemRaycast.cast_to.x = -32
		if Input.is_action_pressed("move_right"):
			horizontal += 1.0
			if !nextToWall():
				player_sprite.scale.x = 1
			$Player_collision.position.x = 1
			$enemy_hitbox/attackingcollision.position.x = 5
			$gem_raycasts/GemRaycast.cast_to.x = 32
	return horizontal
	

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func jump(object):
	if Global.player_health > 0:
		if is_on_floor() or timeSinceLastGrounded < JUMP_DELAY_TIME or nextToWall() or object != self:
			isJumping = true
			velocity.y = jump_velocity
			velocity.y = JUMP_FORCE
		elif double_jump_enabled && double_jumps_used < MAX_DOUBLE_JUMPS and can_double_jump:
			#print("double_jump")
			double_jumps_used += 1
			can_double_jump = false  # Deaktiviere Double Jump, da er jetzt verwendet wurde
			isJumping = true
			velocity.y = jump_velocity
			velocity.y = JUMP_FORCE

var current_attack_anim = 1

func update_player_state():
	if Global.player_health > 0:
		if velocity == Vector2.ZERO and direction == Vector2.ZERO and playerState != PlayerState.ATTACK:
			playerState = PlayerState.IDLE
			$player_animations.play("idle")
		if nextToWall() and playerState != PlayerState.ATTACK and velocity.y != 0:
			playerState = PlayerState.WALL_SLIDE
			$player_animations.play("wall_slide")
		if velocity.x != 0 and playerState != PlayerState.ATTACK && velocity.y == 0:
			playerState = PlayerState.RUN
			$player_animations.play("running")
			if $Audio/Footsteps/Timer.time_left <= 0:
				$Audio/Footsteps.pitch_scale = rand_range(0.8, 1.2)
				$Audio/Footsteps.play()
				$Audio/Footsteps/Timer.start(0.3)
		if (velocity.x == wallJump or velocity.x == -wallJump) and playerState != PlayerState.ATTACK:
			playerState = PlayerState.RUN
			$player_animations.play("running")
		if Input.is_action_just_pressed("attack") and playerState != PlayerState.ATTACK:
			playerState = PlayerState.ATTACK
			if current_attack_anim == 1:
				$player_animations.play("attack_1")
				current_attack_anim = 2
			elif current_attack_anim == 2:
				$player_animations.play("attack_2")
				current_attack_anim = 3
			elif current_attack_anim == 3:
				$player_animations.play("attack_3")
				current_attack_anim = 1
			var hitAudioInstance = hitAudioPlayer.instance()
			get_tree().root.add_child(hitAudioInstance)

		if velocity.y < 0 and playerState != PlayerState.ATTACK:
			playerState = PlayerState.JUMP
			$player_animations.play("jump")
		if velocity.y > 0 and !nextToWall() and playerState != PlayerState.ATTACK:
			playerState = PlayerState.FALL
			$player_animations.play("fall")
		if velocity.y > 0 and Input.is_action_just_pressed("attack"):
			playerState = PlayerState.ATTACK
			if current_attack_anim == 1:
				$player_animations.play("attack_1")
				current_attack_anim = 2
			elif current_attack_anim == 2:
				$player_animations.play("attack_2")
				current_attack_anim = 3
			elif current_attack_anim == 3:
				$player_animations.play("attack_3")
				current_attack_anim = 1
	else:
		playerState = PlayerState.DEAD
		$player_animations.play("die")

		
#	if Input.is_action_pressed("mb_right"):
## warning-ignore:return_value_discarded
#		get_tree().reload_current_scene()




func _on_change_skin_pressed():
	Playerdata.set_skin("Icon")
	update_player_skin()


	
func nextToWall():
	return next_to_right_wall() or next_to_left_wall()

func next_to_right_wall():
	var rightRaycasts = $WallRaycasts/RightWallRaycasts.get_children()
	for raycast in rightRaycasts:
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
				#print(collision_position)
				return true
	return false

func next_to_left_wall():
	var leftRaycasts = $WallRaycasts/LeftWallRaycasts.get_children()
	for raycast in leftRaycasts:
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
				#(collision_position)
				return true
	return false
	
func update_player_skin():
	var currentSkin = Playerdata.selectedSkin
	player_sprite.texture = Unlockables.skins[currentSkin][0]
			
			
func updateParticles():
	var particles = Playerdata.selectedParticle
	var particle_node = $particles
	for child in particle_node.get_children():
		child.queue_free()
	particle_node.add_child(particles.instance())


func _on_Attack_animation_finished():
	playerState = PlayerState.IDLE

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("enemy"):
		var hitAnimInst = hitAnim.instance()
		hitAnimInst.global_position = ((body.global_position + $enemy_hitbox/attackingcollision.global_position) / 2)
		get_tree().current_scene.add_child(hitAnimInst)
		if body.has_method("apply_knockback"):
			var enemy_direction = (body.global_position - global_position).normalized()
			var enemy_strength = 900
			body.apply_knockback(enemy_direction, enemy_strength)
		if randf() < get_node("/root/Playerdata").getStat("critical_damage_chance"):
					#print("critical_hit")
			body.getHit(20, true, self)
		else:
			body.getHit(10, false, self)
	elif body.is_in_group("chest"):
		body.open_chest = true

	
func player_state_to_string(state: int) -> String:
	if state == PlayerState.IDLE:
		return "IDLE"
	elif state == PlayerState.RUN:
		return "RUN"
	elif state == PlayerState.WALL_SLIDE:
		return "WALL SLIDE"
	elif state == PlayerState.ATTACK:
		return "ATTACK"
	elif state == PlayerState.JUMP:
		return "JUMP"
	elif state == PlayerState.FALL:
		return "FALL"
	elif state == PlayerState.DEAD:
		return "DIE"
	else:
		return "UNKNOWN STATE"

func _on_enddoorarea_area_entered(area):
	if area.is_in_group("end_door"):
		print_debug("entered")
		$CanvasLayer/interface/CaveButton.show()
		$CanvasLayer/interface/HomeButton.show()
	


func _on_enddoorarea_area_exited(area):
	if area.is_in_group("end_door"):
		print_debug("exited")
		$CanvasLayer/interface/CaveButton.hide()
		$CanvasLayer/interface/HomeButton.hide()

func _attack_timer():
	timer_active = false

func change_player_speed(factor_percent: float):
	# Berechnen Sie die Änderung basierend auf dem Prozentsatz
	var speed_change = speed * (factor_percent / 100.0)

	# Überprüfen Sie, ob die resultierende Geschwindigkeit nicht negativ wird
	if speed + speed_change >= 0:
		speed += speed_change


func _on_player_animations_animation_finished(anim_name):
	if anim_name == "attack_1" or anim_name == "attack_2" or anim_name == "attack_3":
		$enemy_hitbox/attackingcollision.disabled = true
		playerState = PlayerState.IDLE
	if anim_name == "die":
		die()
			
func apply_knockback(_knockback_direction: Vector2, _strength: float):
	if _knockback_direction.y > 0:
		_knockback_direction.y *= -1
	knockback_direction = _knockback_direction.normalized() * (_strength / 4)
	knockback_strength = _strength
	movement_disabled = true
	velo_reset = true
	knockback = true
	
func getHit(_damage : int, _critical : bool, object):
	hit_anim_player.play("hitAnim")
	#get_node("CanvasLayer/damage_indicator/AnimationPlayer").play("hit")
	_critical = false
	if !object.is_in_group("toxic"):
		var blood_instance = BLOOD.instance()
		get_parent().add_child(blood_instance)
		blood_instance.global_position = global_position
		blood_instance.rotation = global_position.angle_to_point(object.global_position)
		var splashAudioInstance = splashAudio.instance()
		get_tree().root.add_child(splashAudioInstance)
	Global.update_player_health(_damage)
	
func die():
	if Global.checkpoint_activated && !Global.checkpoint_used:
		global_position = Global.checkpoint_position
		Global.checkpoint_used = true
		Global.player_health = (Playerdata.getStat("health") / 2)
		Global.checkpoint_activated = false
		
	elif (!Global.checkpoint_activated or Global.checkpoint_used):
		# Adds the Statistic Screen
		_open_statistics()
		
func _on_astronaut_tree_entered():
	Global.player = self


func _on_astronaut_tree_exited():
	Global.player = null

func _open_statistics():
	add_child(STATISTICS.instance())


func _on_player_animations_animation_started(anim_name):
	if anim_name == "attack_1" or anim_name == "attack_2" or anim_name == "attack_3":
		$enemy_hitbox/attackingcollision.disabled = false
