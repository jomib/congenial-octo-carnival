extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const FALL_ACCELERATION = 75
const DASH_ACCELERATION = 40
const LAVA_DAMAGE_RATE = 0.5;
const DASH_COOLDOWN_TIME_SECONDS = 0.5


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var health = 100.0;

@onready var attack_basic = $Pivot/sword_anchor/AttackMoves
@onready var player_health = $HealthBar
@onready var dash_duration_timer = $Dash_DurationTimer
@onready var dash_cooldown_timer = $Dash_CooldownTimer
#@onready var attack_special = $Pivot/SpecialAttack

@onready var left_leg_joint = $Pivot/model/left_leg_joint/Node3D
@onready var right_leg_joint = $Pivot/model/right_leg_joint/Node3D
@onready var model = $Pivot/model
@onready var torch_anchor = $Pivot/model/torch_anchor
@onready var sword_anchor = $Pivot/sword_anchor

func _ready():
	pass
func _input(event):
	if Input.is_action_just_pressed("attack"):  
		attack_basic.get_node("AnimationPlayer").play("basic_attack")
	if Input.is_action_just_pressed("special"):
		$SpecialAttack_CCTimer.start(0.5)
		attack_basic.get_node("AnimationPlayer").play("special_attack")

var target_velocity = Vector3.ZERO

var move_time = 0.0
func _physics_process(delta):
	update_health()
	
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(position + direction, Vector3.UP)
		
	var direction_facing = $Pivot.transform.basis.z
	
	
	if not $SpecialAttack_CCTimer.is_stopped():
		return

	left_leg_joint.set_identity()
	right_leg_joint.set_identity()
	model.set_identity()
	sword_anchor.set_identity()
	torch_anchor.set_identity()

	if not dash_duration_timer.is_stopped():
		# TODO disable cape physics during dash, use alternate mesh for dash
		# and reset to new softbody mesh when done dashing.
		target_velocity = direction * DASH_ACCELERATION
		left_leg_joint.rotate_x(-PI/2)
		right_leg_joint.rotate_x(-PI/2)
		model.rotate_x(-0.6)
		#sword_anchor.translate(Vector3(0.0, 0.0, 0.5))
		#torch_anchor.translate(Vector3(0,0,0.5))
	else:	
		if Input.is_action_just_pressed("ui_select") and dash_cooldown_timer.is_stopped():
			dash_duration_timer.start(0.1)
			dash_cooldown_timer.start(DASH_COOLDOWN_TIME_SECONDS)
			move_time = 0.0
		else:
			# Ground Velocity
			target_velocity.x = direction.x * SPEED
			target_velocity.z = direction.z * SPEED
		if direction != Vector3.ZERO:
			move_time += delta
			left_leg_joint.rotate_x(sin(move_time * 8.0) * PI/2)
			right_leg_joint.rotate_x(-sin(move_time * 8.0) * PI/2)
		else:
			move_time = 0.0
	

	# Vertical Velocity
	#if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		#target_velocity.y = target_velocity.y - (FALL_ACCELERATION * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()

func update_health():
	player_health.value = health
	
	# Test for lava damage:
	if dash_duration_timer.is_stopped():
		var test_point = self.global_position
		test_point.y -= 1.0;
		var space_state = get_world_3d().direct_space_state
		var ground_query = PhysicsPointQueryParameters3D.new()
		ground_query.set_position(test_point)
		var result = space_state.intersect_point(ground_query)
		if result.size() == 0:
			health -= LAVA_DAMAGE_RATE;
			
func take_damage(amount):
	health -= amount
	if health <= 0.0:
		get_tree().change_scene_to_file("res://menu.tscn")
