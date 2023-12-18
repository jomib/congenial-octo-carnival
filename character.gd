extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const FALL_ACCELERATION = 75
const DASH_ACCELERATION = 40

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var dash_state = false

@onready var animation = $AnimationPlayer
@onready var hitbox_animation = $Hitbox/HitboxCollission/AnimationPlayer

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		animation.play("sword_swing")
		hitbox_animation.play("hitbox")

var target_velocity = Vector3.ZERO

func _physics_process(delta):
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
				
	if not $Dash.is_stopped():
		target_velocity = direction * DASH_ACCELERATION
	else:	
		if Input.is_action_just_pressed("ui_select"):
			$Dash.start(0.1)
		else:
			# Ground Velocity
			target_velocity.x = direction.x * SPEED
			target_velocity.z = direction.z * SPEED
	

	# Vertical Velocity
	#if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		#target_velocity.y = target_velocity.y - (FALL_ACCELERATION * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
#
	## Handle jump.
	##var jump = false
	##if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		##velocity.y = JUMP_VELOCITY
		##jump = true
		#
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#print(direction)
	##if (not jump and is_on_floor()):
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()


func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy"):
		print("get shit on")
