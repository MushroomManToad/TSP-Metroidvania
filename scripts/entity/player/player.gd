class_name PlayerController

extends CharacterBody2D

# Movement Vars
var vel_walking : Vector2 = Vector2(0.0, 0.0)
var vel_gravity : Vector2 = Vector2(0.0, 0.0)
var vel_launch : Vector2 = Vector2(0.0, 0.0)

# Previous frame movement (should never write to this outside of main physics loop)
# Access with getter and setter
var previous_frame_vel : Vector2 = Vector2(0.0, 0.0)

# Current I-Frames
var i_frames : int = 0

# Import Vars
@onready var player_sprite : AnimatedSprite2D = $PlayerSprite
@onready var attack_box: PlayerAttackBox = $AttackBox
@onready var attack_collision_shape: CollisionShape2D = $AttackBox/AttackCollisionShape

# Variable to track player facing direction for movement, dash, and render.
# NOT Computed using Facing.transform()
var facing : int = Facing.RIGHT

# Import vars from other parts of the player.
# These may be read from other classes but should NEVER be set.
@export var player_data : PlayerData
@export var player_hurtbox : PlayerHurtbox
@export var player_interact_box : PlayerInteractBox

# Signals emitted to player data
signal jumped

###### Main Physics Loop ######
func _physics_process(delta: float) -> void:	
	## Reduce i-frames each frame.
	i_frames = max(0, i_frames - 1)
	
	## Compute Jump Velocity.
	# Affects vel_gravity
	jump_physics_process(delta)
	
	## Compute Walk Velocity
	# Affects vel_walking
	walk_physics_process(delta)
	
	## Compute Dash Velocity
	# Affects vel_gravity and vel_walking
	# Overwrites the movements given by the prior two movements.
	dash_physics_process(delta)
	
	## Compute Attack
	# Can affect all velocity variables.
	# Runs after all other calculations as attacks generally stop
	# all ongoing motion.
	attack_physics_process(delta)
	
	## Compute Parry
	# Can affect all velocity variables.
	# Runs after all other calculations as attacks generally stop
	# all ongoing motion.
	parry_physics_process(delta)
	
	## Compute Launch
	# If a launch has been triggered, eat every other input value and launch,
	# cancelling all in-progress attacks, dashes, and parries.
	launch_physics_process(delta)
	
	# Velocity is the sum of all component velocities
	velocity = vel_walking + vel_gravity + vel_launch

	# Stores the true velocity of the previous frame for walk accelerations
	# Note that this does not include frame-lag scalings, as scaling is done
	# Post-calculations.
	set_previous_frame_velocity(velocity)
	
	# Fixes lag making movement inconsistent (without this, CPU lag
	# could give additional jump height or make other movement inconsistent)
	# Needed because move_and_slide uses delta in its calculations.
	velocity *= 1.0 / (60.0 * delta)
	# Let the velocity interact with Godot Physics Engine
	move_and_slide()
	
	# Cancel horizontal momentum on wall collide.
	if is_on_wall():
		if -get_wall_normal().x == Facing.transform(facing):
			set_previous_frame_velocity(Vector2(0.0, get_previous_frame_velocity().y))

###### Used for input capture ######
# We use this variant to ensure the GUI input capture happens first automatically
# Call event.set_input_as_handled() to consume.
func _unhandled_input(event: InputEvent) -> void:
	# Each individual input check returns true on event consumption, 
	# allowing function to immediately exit.
	if jump_input(event):
		get_viewport().set_input_as_handled()
		pass
	if walk_input(event):
		get_viewport().set_input_as_handled()
		pass
	if dash_input(event):
		get_viewport().set_input_as_handled()
		pass
	if attack_input(event):
		get_viewport().set_input_as_handled()
		pass

## Used to set Invulnerability Frames. Ensures that adding I-Frames only
## affects total I-Frame counter if new amount would be greater than current
## I-Frame amount. 
# Note: I-Frames are not additive, but rather a set timer ticking down.
# This method ensures that i_frames remember only the longest active source.
func add_i_frames(amount : int):
	if amount > i_frames:
		i_frames = amount

# Getter and setter for previous frame velocity.
func set_previous_frame_velocity(vel : Vector2) -> void:
	previous_frame_vel = vel

func get_previous_frame_velocity() -> Vector2:
	return previous_frame_vel

###############################################################################
##                                                                           ##
##                               JUMP LOGIC                                  ##
##                                                                           ##
###############################################################################

## Controllers
# Core Variables for vertical speeds.
const JUMP_VELOCITY = -150.0
const GRAVITY = 10
# Duration (frames) that jump can be held to 
const MAX_JUMP_TIME : int = 11
# Max time (frames) a jump can be buffered for
const MAX_JUMP_BUFFER_TIME : int = 10
# First frame of jump downscale of height -- UNUSED
# const DOWNSCALE_FIRST_JUMP_FRAME : float = 3.0
# Max coyote time (frames)
const MAX_COYOTE_TIME : int = 6
# Maximum fall velocity
const MAX_FALL_SPEED : float = 1000.0

# True when jump has been pressed and not yet consumed by jump start.
var jump_buffered : bool = false
# Used to track how long (frames) a jump has been buffered
var jump_buffered_time : int = 0

# Current Coyote Time. Player can jump when less than MAX_COYOTE_TIME and
# in air (frames)
var coyote_time_elapsed : int = 0

# Jump input state tracker.
var jump_held : bool = false

# Variable to track how long the jump button has been held for (frames).
var jumping_time : int = 0

# Variable to track if a double jump is charged
var double_jump_charged : bool = false

# Core loop running every physics frame for jumping.
## 1) If on ceiling, bonk (jump_time = max_jump_time and vertical velocity reset)
## 2) If not on the floor, add fall speed, else reset fall speed. (Gravity)
##		2.1) If on floor, restore double jump charge.
## 3) If a jump is buffered and on floor, jump and max out coyote timer:
## 		3.1) If coyote time less than max, jump and max out coyote timer
##		3.2) Else if double jump is charged, start a double jump
##		3.3) Else increase jump buffer timer.
## 4) If not on floor, increment Coyote Timer, else reset coyote timer.
## 5) If jump is held and we haven't jumped too long, keep ascending
##		5.1) If player is on the floor, reset jumping time since the jump has ended early
##		5.2) Increment jumping_timer by 1
##		5.3) If player has been jumping too long, reset jumping_time to end jump.
func jump_physics_process(delta: float) -> void:	
	# "Ceiling Bonks" by setting jump time to max. Could technically animate here too.
	if is_on_ceiling():
		jumping_time = MAX_JUMP_TIME
		vel_gravity.y = 0.0
	
	# Add the gravity.
	if not is_on_floor():
		vel_gravity.y += GRAVITY + (GRAVITY * 0.5 if velocity.y < 0 else 0.0)
		vel_gravity.y = min(vel_gravity.y, MAX_FALL_SPEED)
	else:
		vel_gravity.y = 0.0
		charge_double_jump()

	# First frame of jump should be shorter, and this sets up the player being
	# in the air for the rest of the jump listener 
	if jump_buffered:
		# First frame of jump should be shorter, and this sets up the player being
		# in the air for the rest of the jump listener 
		if is_on_floor() or (not is_on_floor() and coyote_time_elapsed <= MAX_COYOTE_TIME):
			start_jump(JUMP_VELOCITY)
		# If not on the floor but has double jump charge, jump
		elif is_double_jump_charged():
			start_jump(- JUMP_VELOCITY / 4.0)
			double_jump_charged = false
		# While not on floor, start tracking how long the jump has been
		# buffered and destroy jump buffer if buffered too long
		else:
			jump_buffered_time += 1
			if jump_buffered_time >= MAX_JUMP_BUFFER_TIME:
				buffer_jump(false)
	
	# Update Coyote Time
	if not is_on_floor():
		coyote_time_elapsed += 1
	elif coyote_time_elapsed != 0: 
		coyote_time_elapsed = 0

	# Handle jump from in the air onward.
	if jump_held and not_jumped_too_long():
		if not is_on_floor():
			vel_gravity.y = JUMP_VELOCITY
		else:
			jumping_time = 0
	# Control the max amount of time the jump botton can be held for for extra height
		jumping_time += 1
	elif jumping_time != 0:
		jumping_time = 0

## Consumes inputs relevant to jumping.
func jump_input(event : InputEvent) -> bool:
	if event.is_action_pressed("Jump"):
		jump_held = true
		buffer_jump(true)
		# Consume input
		return true
	if event.is_action_released("Jump"):
		jump_held = false
		buffer_jump(false)
		# Consume input
		return true
	# Input is not consumed
	return false

func not_jumped_too_long() -> bool:
	# Jump is valid if they are mid jump in the air and still have jump time.
	return jumping_time > 0 and jumping_time < MAX_JUMP_TIME 

func start_jump(velocity_y : float):
	# Un-buffer jump
	buffer_jump(false)
	# Must always do this on jump to prevent double-tap shenanigans
	coyote_time_elapsed = MAX_COYOTE_TIME
	# Have the first frame lower the player a la Hollow Knight
	vel_gravity.y = velocity_y
	# Gives a jump the "initial push" needed for the rest of the
	# jump loop to take over (requires jumping_time > 0.0)
	jumping_time += 1
	jumped.emit()

# Call to buffer a jump - contains extra reset logic.
func buffer_jump(val : bool) -> void:
	jump_buffered = val
	if val == false:
		jump_buffered_time = 0

## Call to cancel an ongoing jump
func cancel_jump() -> void:
	jumping_time = MAX_JUMP_TIME

## Helper methods for double jump handling
func charge_double_jump() -> void:
	double_jump_charged = true

func is_double_jump_charged() -> bool:
	## TODO: Additional logic for before double jump is unlocked
	## Or when it is disabled.
	return double_jump_charged

###############################################################################
##                                                                           ##
##                               JUMP LOGIC                                  ##
##                                                                           ##
###############################################################################


###############################################################################
##                                                                           ##
##                               WALK LOGIC                                  ##
##                                                                           ##
###############################################################################
# Horizontal Base Walk Speed
const WALK_SPEED : float = 100.0
# When dash is held, speed increases by this multiplier on the ground
const SPRINT_MULTIPLIER : float = 1.5

const WALK_ACCEL_GROUNDED : float = 33.3
const WALK_ACCEL_AIRBORN : float = 33.0

# Directional input trackers
var left_held : bool = false
var right_held : bool = false
var up_held : bool = false
var down_held : bool = false

# -1 or 1 (Facing.transform) when sprinting, 0 otherwise.
# Set on holding dash button while on the ground on a frame where walk is calcutlated
# And on the last frame of a dash.
# Reset when turning around in the air after a jump.
# Reset when sprint is released
var sprint_direction : int = 0

# Core loop running every physics frame for walking/running.
func walk_physics_process(delta : float):
	# No walking logic should run while a dash is ongoing
	if can_walk():
		# Get the input direction and handle the movement/deceleration.
		# Leave this as an input call for realtime strength reading for controller
		var stick_strength := clampf(Input.get_axis("Left", "Right"), -1.0, 1.0)
		
		# Variable that determines the current walking  strength and direction.
		## Value is amount horizontal movement changes from the previous frame.
		# Keep as positive, as this will be used as the delta in later calculations.
		var walking_affect : float = 0.0
		# If grounded, use Grounded accel value, else use Airborn accel value.
		if is_on_floor():
			walking_affect = WALK_ACCEL_GROUNDED
		else:
			walking_affect = WALK_ACCEL_AIRBORN
		
		# Runs if any input is given.
		if stick_strength:
			# If input is given, adjust the accel affect to correspond to amount
			# joystick is moved. -- Actually, don't do this, leads to friction bug.
			##walking_affect *= abs(stick_strength)
			# Move towards moves from arg0 to arg1 by delta arg2. Here, we move
			# from the previous frame's velocity towards the walk speed (accounting
			# for "sprinting" and stick strength) by the previously calculated
			# delta, called "walking_affect"
			vel_walking.x = move_toward(previous_frame_vel.x, walk_speed(stick_strength), walking_affect)
			player_sprite.play("player_run")
			# Turn the player if and only if they are not attacking
			if not is_attacking():
				if stick_strength < 0:
					turn_player(Facing.LEFT)
				else:
					turn_player(Facing.RIGHT)
		# Runs when neither left nor right is held (over deadzone threshold)
		else:
			# Decelerate towards 0 speed
			vel_walking.x = move_toward(previous_frame_vel.x, 0, walking_affect)
			player_sprite.play("player_idle")

## Function to check if walking logic should be used this frame
func can_walk() -> bool:
	# Player must not be dashing
	# Player must not be launch stunned
	return not is_dashing() and launch_stun_timer <= 0

## Consumes inputs relevant to jumping.
# Return true to consume event
func walk_input(event : InputEvent) -> bool:
	var consume_flag : bool = false
	if event.is_action_pressed("Left"):
		left_held = true
		# Consume input
		consume_flag = true
	if event.is_action_released("Left"):
		left_held = false
		# Consume input
		consume_flag = true
	if event.is_action_pressed("Right"):
		right_held = true
		# Consume input
		consume_flag = true
	if event.is_action_released("Right"):
		right_held = false
		# Consume input
		consume_flag = true
	if event.is_action_pressed("Up"):
		up_held = true
		on_interacts()
		# Consume input
		consume_flag = true
	if event.is_action_released("Up"):
		up_held = false
		# Consume input
		consume_flag = true
	if event.is_action_pressed("Down"):
		down_held = true
		# Consume input
		consume_flag = true
	if event.is_action_released("Down"):
		down_held = false
		# Consume input
		consume_flag = true
	return consume_flag

## Utility function -- call to turn the player
func turn_player(direction : int) -> void:
	match direction:
		Facing.LEFT:
			facing = Facing.LEFT
			player_sprite.scale = Vector2(-1.0, 1.0)
		Facing.RIGHT:
			facing = Facing.RIGHT
			player_sprite.scale = Vector2(1.0, 1.0)

# Function for computing the walk speed at any time based on stick strength.
func walk_speed(stick_strength : float) -> float:
	# Base walk speed
	var vel = WALK_SPEED
	# Scale the velocity by how hard the stick is held.
	vel *= stick_strength
	# If dash is held, then multiply speed by SPRINT_MULTIPLIER if sprint
	# direction is set. 
	if dash_held:
		# Set sprint direction if on the floor (while dash is held)
		if is_on_floor():
			sprint_direction = Facing.transform(facing)
		# If facing the same way as sprint started, keep sprinting
		if sprint_direction == Facing.transform(facing):
			vel *= SPRINT_MULTIPLIER
		# Reset sprint direction if we have turned in the air (since if we
		# turned on the ground, this value would have updated earlier)
		else:
			sprint_direction = 0
	# Reset sprint direction if dash is not held
	else:
		sprint_direction = 0
	return vel

###############################################################################
##                                                                           ##
##                               WALK LOGIC                                  ##
##                                                                           ##
###############################################################################



###############################################################################
##                                                                           ##
##                               DASH LOGIC                                  ##
##                                                                           ##
###############################################################################

# Max number of frames dash can be buffered
const DASH_BUFFER_LEEWAY : int = 3
# Dash max cooldown (frames)
const DASH_COOLDOWN : int = 46
# Dash duration
const DASH_DURATION : int = 10
# Dash Speed 
const DASH_SPEED : float = 300

# Dash buffer tracker - consumed on Dash started
var dash_buffered : bool = false
# Dash input tracker
var dash_held : bool = false
# Tracks whether a dash is charged. In general, consumed on dash, refilled on
# ground touch, aerial hit, etc. Can only dash when charged.
var dash_charged : bool = true
# Dash cooldown tracker
var dash_cooldown : int = 0
# Dash duration elapsed so far (frames)
var dash_duration_elapsed : int = 0
# Tracks how long dash has been buffered.
var dash_buffered_duration : int = 0
# Tracks the direction of the dash 
# Not transformed.
var dash_direction : int

# Core loop running every frame to compute a dash.
## 1) "Recharge" (make available) a dash if on the floor
## 2) Tick down dash cooldown.
## 3) If a dash has been buffered, increment the timer and cancel the dash
##        if it has been buffered for too long
## 4) If a dash is buffered, the dash is off cooldown, and dash is charged,
##        then start the dash
## 4.1) To do this, first set dash duration elapsed to 1. This signals a dash
##          has been started. 
## 4.2) Then, unbuffer all dashes, since we are now in a dash.
## 4.3) Also, uncharge dash, since we are now expending the charge.
## 4.4) Finally, set the dash direction to the current facing direction to
##          prevent turning mid-dash.
## 5) If we are currently dashing and dash hasn't lasted too long, then:
## 5.1) Increment dash timer, and adjust relevant velocities.
## 5.2) Otherwise, end the dash (duration -> 0) and set the final frame velocity
func dash_physics_process(delta : float) -> void:
	# Charge dash if on the floor
	if !dash_charged and is_on_floor():
		charge_dash()
	
	# Tick down dash cooldown if applicable
	dash_cooldown = max(0, dash_cooldown - 1)
	
	# Handle dash buffer duration to cancel dashes buffered too long.
	if dash_buffered:
		# Increment Dash Buffer Timer here to leaving the timer as 1
		dash_buffered_duration += 1
		# If a dash has been buffered too long, cancel all buffered dashes.
		if dash_buffered_duration > DASH_BUFFER_LEEWAY:
			buffer_dash(false)
	
	# If a dash has been buffered and dash is off cooldown and dash is charged, 
	# then start a dash.
	if can_dash():
		# Set this variable to 1 to begin the dash. (Timer counts up to 
		# dash max duration inclusive, so this says we are in the first frame.)
		dash_duration_elapsed = 1
		# Unbuffer all buffered dashes
		buffer_dash(false)
		# Set Dash Cooldown to Max
		dash_cooldown = DASH_COOLDOWN
		# Uncharge dash (so it needs to be refilled by ground touch or hit)
		dash_charged = false
		# Set dash direction based on facing direction for remembering it 
		# through potential momentum/input updates
		dash_direction = facing
	
	# If we are in a dash, then do the dash.
	# This check relies on dash_duration_elapsed.
	if is_dashing():
		# Increment Dash Duration
		dash_duration_elapsed += 1
		# Override vertical velocity so the player doesn't fall.
		vel_gravity.y = 0
		vel_walking.x = DASH_SPEED * Facing.transform(dash_direction)
	
	# Once dash_duration_elapsed is outside of this range, reset dash duration
	# since the dash is done.
	elif dash_duration_elapsed > 0:
		# Set the velocity to match the previous frame velocity in case of
		# dashing into a wall (this fixes a 1-pixel bug.)
		vel_walking.x = get_previous_frame_velocity().x
		# Reset the dash.
		cancel_dash()

## Function to test if a dash can start
func can_dash() -> bool:
	# Dash must be input (dash_buffered)
	# Dash must be off cooldown
	# Dash must be charged (i.e. ground has been touched or attack reset dash)
	# The player cannot be in launch stun
	return dash_buffered and dash_cooldown == 0 and dash_charged and launch_stun_timer <= 0

## Call to cancel an ongoing dash
func cancel_dash() -> void:
	# This should be as simple as setting the duration of the dash to 0.
	dash_duration_elapsed = 0

# Capture Dash Input
func dash_input(event : InputEvent) -> bool:
	if event.is_action_pressed("Dash"):
		dash_held = true
		buffer_dash(true)
		# Consume input
		return true
	if event.is_action_released("Dash"):
		dash_held = false
		# Do not cancel a buffered dash on dash release
		# Consume input
		return true
	return false

# Call to buffer a dash or reset the dash buffered value.
func buffer_dash(val : bool) -> void:
	if val:
		# Only buffer dash if it's off cooldown or about to be off cooldown
		if dash_cooldown <= DASH_BUFFER_LEEWAY:
			dash_buffered = true
			# Reset this timer since a new input has been given/dash buffered
			dash_buffered_duration = 0
	else:
		dash_buffered = false
		# Reset this timer since a no dash is buffered
		dash_buffered_duration = 0

# Use this function to test if the player is currently in a dash - used to
# prevent things such as turning while dashing.
func is_dashing() -> bool:
	# Note that the <= handles the first frame ending in the duration being 2
	# to make detection of the dash start easier.
	return dash_duration_elapsed > 0 and dash_duration_elapsed <= DASH_DURATION

# Function to charge dash. Here in case additional logic is needed.
func charge_dash() -> void:
	dash_charged = true

func end_dash_cd() -> void:
	dash_cooldown = 0

###############################################################################
##                                                                           ##
##                               DASH LOGIC                                  ##
##                                                                           ##
###############################################################################



###############################################################################
##                                                                           ##
##                              ATTACK LOGIC                                 ##
##                                                                           ##
###############################################################################

# Number of frames after the button is pressed (or buffer is released)
# that the attack hitbox appears. Used for windup animation.
var ATTACK_WINDUP_FRAMES : int = 1
# Duration of the attack after the windup
var ATTACK_FRAMES : int = 9
# Attack Cooldown
var ATTACK_MAX_COOLDOWN : int = 20
# Max time attack can be buffered for.
var ATTACK_MAX_BUFFER : int = 2

# Current attack cooldown
var attack_cooldown : int = 0

# Tracks if the attack button is currently held down.
var attack_held : bool = false

# Variables for attack buffer - if buffered and for how long respectively
var attack_buffered : bool = false
var attack_buffered_duration : int = 0

# Current attack duration
var attack_duration : int = 0

# Tracks attack direction to make sure player does not turn. Not transformed.
var attack_facing_direction : int

# Tracks the direction of the attack for attack box calculation and knockback purposes
var attack_direction : int

func attack_physics_process(delta : float):
	# Tick down attack cooldown if applicable
	attack_cooldown = max(0, attack_cooldown - 1)
	
	# If an attack is valid and the attack is buffered, then attack.
	if attack_buffered and can_attack():
		# Unbuffer attack
		buffer_attack(false)
		# Lock attack facing direction
		attack_facing_direction = facing
		# Find attack direction (CardinalDirection)
		if up_held and not down_held:
			attack_direction = CardinalDirections.UP
		elif down_held and not up_held and not is_on_floor():
			attack_direction = CardinalDirections.DOWN
		else:
			attack_direction = CardinalDirections.LEFT if facing == Facing.LEFT else CardinalDirections.RIGHT
		# Start attack timer (tells the rest of the loop to update)
		attack_duration = 1
		# Set cooldown to max since attack was just used.
		attack_cooldown = ATTACK_MAX_COOLDOWN
		
	# If an attack is buffered but invalid, increment buffer timer
	elif attack_buffered:
		attack_buffered_duration += 1
		# If buffer timer exceeds max, then unbuffer the attack.
		if attack_buffered_duration > ATTACK_MAX_BUFFER:
			buffer_attack(false)
	
	# Loop runs when an attack is currently happening.
	if attack_duration > 0:
		# Increment attack timer
		attack_duration += 1
		## TODO: on the first frame, start the attack animation.
		if attack_duration == 1:
			pass
		# If on the first frame after windup, spawn the attack hitbox
		if attack_duration == ATTACK_WINDUP_FRAMES + 2:
			spawn_attack_box()
		## TODO: handle attacking while the attack box is spawned.
		if attack_duration > ATTACK_WINDUP_FRAMES + 1:
			pass 
		# End the attack once the full duration has elapsed.
		if attack_duration > ATTACK_WINDUP_FRAMES + ATTACK_FRAMES + 1:
			# This function contains all attack ending logic, set aside
			# in case an attack ever needs to be cancelled for other reasons
			# (i.e. taking damage)
			end_attack()

# Capture Attack Input
func attack_input(event : InputEvent) -> bool:
	if event.is_action_pressed("Attack"):
		attack_held = true
		# Can always buffer attack on press, 
		# This helps with mashing remaining accurate per frame.
		buffer_attack(true)
		# Consume input
		return true
	if event.is_action_released("Attack"):
		attack_held = false
		# Do not cancel a buffered attack on attack release
		# Consume input
		return true
	return false

## Function returns true if player is currently in an attack, false otherwise.
func is_attacking() -> bool:
	# An attack is happening if the duration is over 0
	return attack_duration > 0

# Returns true if all conditions are met to consume a buffered attack. Else false.
func can_attack() -> bool:
	# Can attack when attack is off cooldown
	if attack_cooldown <= 0:
		return true
	# Return false otherwise.
	return false

# Call to buffer an attack or reset the attack buffered value.
func buffer_attack(val : bool):
	if val:
		attack_buffered = true
	else:
		attack_buffered = false
	attack_buffered_duration = 0

## Call this function to spawn an attack box.
func spawn_attack_box():
	# Attack box method for enabling it and determining position
	attack_box.start_new_attack()

## Call this function to end an ongoing attack for any reason. 
func end_attack():
	attack_duration = 0
	attack_box.end_attack()

###############################################################################
##                                                                           ##
##                              ATTACK LOGIC                                 ##
##                                                                           ##
###############################################################################



###############################################################################
##                                                                           ##
##                              PARRY  LOGIC                                 ##
##                                                                           ##
###############################################################################

func parry_physics_process(delta : float):
	pass

###############################################################################
##                                                                           ##
##                              PARRY  LOGIC                                 ##
##                                                                           ##
###############################################################################



###############################################################################
##                                                                           ##
##                              LAUNCH LOGIC                                 ##
##                                                                           ##
###############################################################################

# List of all attack launches for this frame. Cleared at end of frame.
var attack_launches_list = []

# List of all override launches for this frame. Cleared at end of frame.
var override_launches_list = []

# List of all non-override launches for this frame. Cleared at end of frame.
var launches_list = []

## Launch stun timer 
# Prevents walking from updating velocity while positive
# Ticks down once every frame AFTER launches are calculated
var launch_stun_timer : int = 0

## For launches that add to all other launches. Applies last.
# Enqueues a launch for this frame.
func enqueue_launch(direction : Vector2):
	launches_list.append(direction)

## For an attack/parry launch. Only one can trigger per frame.
# Enqueues a launch for this frame. 
# Overrides previous movement vectors IF opposite attack
func enqueue_attack_launch(direction : Vector2):
	# Only append if this is the first launch this frame of this type.
	if attack_launches_list.is_empty():
		attack_launches_list.append(direction)
	# OR append if this launch is stronger than the previous lanches
	elif (attack_launches_list[0] as Vector2).length_squared() < direction.length_squared():
		attack_launches_list[0] = direction

## For launches that add to all other launches and override previous movement
# Enqueues a launch for this frame. Overrides previous movement vectors.
func enqueue_override_launch(direction : Vector2):
	override_launches_list.append(direction)


func launch_physics_process(delta: float):
	# First, do the override launches
	# If there are any, cancel all previous velocities
	if not override_launches_list.is_empty():
		vel_walking = Vector2(0.0, 0.0)
		vel_gravity = Vector2(0.0, 0.0)
	
	for l in override_launches_list:
		vel_walking.x += l.x
		vel_gravity.y += l.y
	
	# Next, handle the attack launches
	# This iterator should hit at most one object
	for l in attack_launches_list:
		var direction : Vector2 = l as Vector2
		# If the sign matches, then add the launch to the walk vel.
		if (direction.x > 0 and vel_walking.x > 0) or (direction.x < 0 and vel_walking.x < 0):
			vel_walking.x += direction.x
		# Else, overwrite the old velocity as long as there is velocity to write
		elif direction.x != 0:
			vel_walking.x = direction.x
		# Mirrored for gravity with y-axis
		if (direction.y > 0 and vel_gravity.y > 0) or (direction.y < 0 and vel_gravity.y < 0):
			vel_gravity.y += direction.y
		# Else, overwrite the old velocity as long as there is velocity to write
		elif direction.y != 0:
			vel_gravity.y = direction.y
	
	# Finally, handle the standard launches
	for l in launches_list:
		# X-component to walking, y-component to gravity
		vel_walking.x += l.x
		vel_gravity.x += l.y
	
	# Then, update any launch stun timers
	launch_stun_timer = max(launch_stun_timer - 1, 0)
	
	# Finally, clear out all launch arrays for listening on the next frame
	attack_launches_list.clear()
	override_launches_list.clear()
	launches_list.clear()

###############################################################################
##                                                                           ##
##                              LAUNCH LOGIC                                 ##
##                                                                           ##
###############################################################################



###############################################################################
##                                                                           ##
##                             COLLIDER LOGIC                                ##
##                                                                           ##
###############################################################################

# Call the interacts of the hurtbox on pressing up.
func on_interacts() -> void:
	player_interact_box.on_interacts()

# Called on current health reaching zero.
func die() -> void:
	## TODO: Death Logic
	pass

func on_damaged() -> void:
	## TODO: On Damaged animation/state handler
	pass

###############################################################################
##                                                                           ##
##                             COLLIDER LOGIC                                ##
##                                                                           ##
###############################################################################
