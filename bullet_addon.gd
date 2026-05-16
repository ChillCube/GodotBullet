@icon("res://addons/GodotBullet/icon_bullet.png")
extends Sprite2D
class_name Projectile2D

@export_group("Collision")
@export var has_collision_shape : bool = true; ## Disable if you want to add your own collision shape or if collision is unnecessary
@export var collision_shape_size : float = 0.8; ## Sets how big the collisionshape will be. 1 = same width as sprite, 2 = double the size of sprite, 0.5 = half the size of the sprite
@export var collision_shape_offset : Vector2 = Vector2.ZERO; ## allows you to offset the position of the collider from the center of the bullet
@export var collision_mask : int = 1; ## Which physics layers the bullet will collide with
@export var collision_layer : int = 1; ## Which physics layer the bullet belongs to

@export_group("Bouncing")
@export var bounces_enabled : bool = false; ## If true, bullet will bounce off surfaces instead of being destroyed
@export var max_bounces : int = 2; ## Maximum number of bounces before the bullet is destroyed (-1 = infinite)
@export var bounce_damping : float = 0.8; ## How much speed is preserved on bounce (1 = no loss, 0 = stop on bounce)
@export var bounce_angle_variance : float = 0; ## Random angle variance on bounce (in degrees, 0 = perfect reflection)
@export var bounce_exception_groups : Array[String] = []; ## Groups that bullet will NOT bounce off (will destroy instead)
@export var bounce_only_groups : Array[String] = []; ## If not empty, ONLY bounce off these groups (others destroy)

@export_group("Speed")
@export var start_speed : float = 100; ## the speed that the bullet starts off with
@export_range(0,1) var relative_falloff : float = 0; ## 0 = no speed will be lost, 1 = bullet will stop instantly, 0.5 = bullet will lose half its speed every frame (Can be combined with constant falloff)
@export var constant_falloff : float = 0; ## will reduce the speed by the given amount each frame. (Can be combined with relative falloff)

@export_subgroup("Boomerang")
@export var boomerang : bool = false; ## if enabled, the bullet will curve back to the return target. WARNING: When enabled, target following is ignored
@export_enum("SPEED_RATIO", "DISTANCE") var boomerang_trigger : int = 0; ## What triggers the boomerang to return: SPEED_RATIO (based on remaining speed) or DISTANCE (based on how far it traveled)
@export_range(0, 1) var boomerang_start_at_speed : float = 0.5; ## If using SPEED_RATIO: 1 = returns when it has lost all speed, 0 = returns immediately, 0.5 = returns when half speed remains
@export var boomerang_start_at_distance : float = 100; ## If using DISTANCE: How far the bullet should travel before returning (in pixels)
@export var boomerang_curve_rate : float = 1.5; ## How quickly the bullet curves back (higher = tighter/faster curve, 1 = gentle curve, 2 = sharp curve)
@export_enum("LEFT", "RIGHT", "RANDOM") var boomerang_curve_direction : int = 0; ## Which direction the curve arcs (0=LEFT, 1=RIGHT, 2=RANDOM)
@export var boomerang_return_target : Node2D = null; ## OPTIONAL: Set a node for the boomerang to return to (like the player). If null, returns to original firing position
@export var dynamic_return_target : bool = false; ## If true, the return target will be checked every frame (useful for moving targets). If false, target is locked at boomerang start
@export var max_return_distance : float = 0; ## OPTIONAL: Maximum distance to return target before destroying (0 = unlimited). Useful for preventing infinite flight

@export_group("Direction")
@export_enum("TARGET_POSITION", "TARGET_NODE", "DIRECTION") var move_using: int = 0; ## decides whether the bullet will move according to a direction or according to a target. NOTE: If boomerang is enabled, this is ignored after returning starts

@export_subgroup("Direction")
@export_range(0, 360) var direction : float ## decides what direction the bullet should move in

@export_subgroup("Target Position")
@export var target_position : Vector2; ## decides what target the bullet should move towards

@export_subgroup("Target Node")
@export var target_node : Node2D; ## set the node that the bullet is meant to target
@export var follow_target : bool = true; ## if enabled, the bullet will keep following that target
@export_range(0, 360) var steering_degrees : float = 360; ## Sets the maximum angle that the bullet can steer each frame towards the target, at 360 the bullet will go directly to the player, at 0 the bullet will go straightforward. Anything between, the bullet will try to curve towards the target

@export_group("Combat")
@export var damage : float = 10; ## Amount of damage this bullet deals on hit

@export_group("end of life")
@export var destroy_on_no_speed : bool = true; ## Decides whether or not the node should be destroyed when its speed reaches 0
@export var destroy_when_colliding : bool = true; ## Decides whether or not the node should be destroyed when it collides with something (overridden by bounce if bounce occurs)
@export var destroy_on_return : bool = true; ## If true, bullet destroys itself after reaching the return target
@export var shrink_on_death : bool = true;
@export var spawn_node_when_destroyed : PackedScene; ## Sets a node that is created when the bullet is destroyed. Can be useful if you want to turn the bullet into an item that can be picked up. Leave empty if no node should be created.

@export_group("Performance")
@export var cull_off_screen : bool = true; ## If true, bullet will be removed when off screen
@export var cull_margin : float = 100; ## Margin around screen before culling

@export_group("Multiplayer")
@export var is_multiplayer_sync : bool = true; ## If true, bullet will sync position across network (auto-detected if multiplayer is active)

# Signals
signal hit_body(body : Node)
signal destroyed(_position : Vector2)
signal boomerang_returned() ## Emitted when the boomerang reaches its return target
signal bounced(hit_node : Node, bounce_count : int, bounce_position : Vector2, new_direction : Vector2, current_speed : float) ## Emitted when bullet bounces - provides hit node, bounce count, position, new direction, and remaining speed

var current_speed : float;
var current_direction : Vector2;
var original_position: Vector2
var original_target_position : Vector2;
var original_speed: float
var is_returning : bool = false;
var shrink : bool = false;
var boomerang_curve_perp : Vector2 = Vector2.ZERO;
var locked_return_target_position : Vector2 = Vector2.ZERO; ## Locked position if dynamic_return_target is false
var original_forward_direction : Vector2 = Vector2.RIGHT; ## Store the original direction for curve calculation
var distance_traveled : float = 0; ## Tracks total distance traveled for distance-based trigger
var current_bounce_count : int = 0; ## Tracks how many times bullet has bounced
var can_bounce : bool = true; ## Used to prevent multiple bounces from same collision
var is_authority : bool = true; ## Whether this instance controls the bullet (server or single player)
var last_synced_position : Vector2 = Vector2.ZERO; ## Last position that was synced
var sync_timer : float = 0; ## Timer for network sync
var sync_interval : float = 0.05; ## How often to sync position (20 times per second)

func _ready() -> void:
	# Determine if this is the authority (controls movement)
	_is_authority()
	
	original_position = global_position
	original_target_position = target_position
	original_speed = start_speed
	current_speed = start_speed
	current_direction = get_initial_direction()
	original_forward_direction = current_direction
	distance_traveled = 0
	current_bounce_count = 0
	last_synced_position = global_position
	
	# Setup boomerang curve direction
	if boomerang:
		var curve_dir = boomerang_curve_direction
		if curve_dir == 2: # RANDOM
			curve_dir = randi() % 2
		
		# Calculate perpendicular vector for the curve (90 degrees to current direction)
		if curve_dir == 0: # LEFT
			boomerang_curve_perp = Vector2(-current_direction.y, current_direction.x)
		else: # RIGHT
			boomerang_curve_perp = Vector2(current_direction.y, -current_direction.x)
		
		# Lock return target position if not dynamic
		if not dynamic_return_target:
			if boomerang_return_target:
				locked_return_target_position = boomerang_return_target.global_position
			else:
				locked_return_target_position = original_position
	
	if has_collision_shape:
		var area = Area2D.new()
		area.collision_mask = collision_mask
		area.collision_layer = collision_layer
		var collider = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = (SpriteHelper.get_width(self) * 0.5) * collision_shape_size
		collider.shape = shape
		collider.position = collision_shape_offset
		area.add_child(collider)
		add_child(area)
		area.connect("body_entered", Callable(self, "_on_body_entered"))
		area.connect("area_entered", Callable(self, "_on_area_entered"))
	
	# Register for multiplayer sync (only if we have a multiplayer peer)
	if is_multiplayer_sync and multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		_setup_multiplayer()

func _is_authority() -> void:
	# Auto-detect authority based on multiplayer configuration
	if not is_multiplayer_sync:
		is_authority = true
		return
	
	# If we're not in a multiplayer game (no peer), treat as authority
	if not multiplayer.has_multiplayer_peer():
		is_authority = true
		return
	
	# In multiplayer, the server is the authority for projectiles
	is_authority = multiplayer.is_server()

func _setup_multiplayer() -> void:
	# Set the node as multiplayer synchronized
	set_multiplayer_authority(str(name).hash())
	
	# The server will sync position to all clients
	if is_authority:
		# Authority processes normally
		pass
	else:
		# Disable local processing on clients by setting a flag
		use_slave_processing = true

# Add this variable at the top with your other vars
var use_slave_processing : bool = false;

# Then modify _process to check this flag instead
func _process(delta: float) -> void:
	# Check if this instance should use slave processing
	if use_slave_processing:
		_process_slave(delta)
		return
	
	# Check if this instance should process movement
	if not is_authority:
		_process_slave(delta)
		return
	
	# Authority processes full bullet logic
	apply_falloff(delta)
	update_direction(delta)
	move_bullet(delta)
	
	if shrink:
		scale -= Vector2(delta, delta) * 40
		if scale.x < 0.05:
			queue_free()
	if cull_off_screen:
		_check_cull()
	can_bounce = true # Reset bounce flag each frame
	
	# Sync position to clients if multiplayer is active
	if is_multiplayer_sync and multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		sync_timer += delta
		if sync_timer >= sync_interval:
			sync_timer = 0
			_rpc_sync_position(global_position, current_direction, current_speed, current_bounce_count, is_returning)

func _process_slave(delta: float) -> void:
	# Clients only receive updates, don't process locally
	# Only handle visual effects (shrink, culling)
	if shrink:
		scale -= Vector2(delta, delta) * 40
		if scale.x < 0.05:
			queue_free()
	if cull_off_screen:
		_check_cull()

@rpc("authority", "call_remote", "reliable")
func _rpc_sync_position(pos: Vector2, dir: Vector2, speed: float, bounce_count: int, returning: bool) -> void:
	# Clients receive sync update
	if not is_authority:
		global_position = pos
		current_direction = dir
		current_speed = speed
		current_bounce_count = bounce_count
		is_returning = returning

func get_initial_direction() -> Vector2:
	match move_using:
		0: # TARGET_POSITION
			return (target_position - global_position).normalized()
		1: # TARGET_NODE
			if target_node:
				return (target_node.global_position - global_position).normalized()
			return Vector2.RIGHT
		2: # DIRECTION
			return Vector2.RIGHT.rotated(deg_to_rad(direction))
	return Vector2.RIGHT

func move_bullet(delta: float) -> void:
	var movement = current_direction * current_speed * delta
	global_position += movement
	# Track distance traveled for distance-based boomerang trigger
	if not is_returning:
		distance_traveled += movement.length()

func update_direction(delta: float) -> void:
	# Handle boomerang - gradual curve to return target
	if boomerang:
		# Check if we should start returning based on trigger type
		if not is_returning:
			var should_return = false
			
			match boomerang_trigger:
				0: # SPEED_RATIO
					if current_speed > 0:
						var speed_ratio = current_speed / original_speed
						if speed_ratio <= boomerang_start_at_speed:
							should_return = true
				1: # DISTANCE
						if distance_traveled >= boomerang_start_at_distance:
							should_return = true
			
			if should_return:
				is_returning = true
		
		# Gradual curve to return target
		if is_returning:
			# Get current return target position (dynamic or locked)
			var current_return_target : Vector2
			if dynamic_return_target and boomerang_return_target:
				current_return_target = boomerang_return_target.global_position
			elif boomerang_return_target:
				current_return_target = locked_return_target_position
			else:
				current_return_target = original_position
			
			# Check max return distance (optional)
			if max_return_distance > 0:
				var distance_to_target = global_position.distance_to(current_return_target)
				if distance_to_target > max_return_distance:
					destroy()
					return
			
			# Calculate direction to return target
			var to_target = (current_return_target - global_position).normalized()
			
			# Blend between forward, curved, and target direction based on curve rate
			var t = clamp(boomerang_curve_rate * delta, 0, 1)
			
			# First blend towards the curve perpendicular (creates the arc)
			var curved_dir = current_direction.lerp(boomerang_curve_perp, t * 0.5)
			# Then blend towards the return target
			var final_dir = curved_dir.lerp(to_target, t)
			
			current_direction = final_dir.normalized()
			
			# Check if reached return target
			var distance_to_target = global_position.distance_to(current_return_target)
			if distance_to_target < 20 and destroy_on_return:
				emit_signal("boomerang_returned")
				destroy()
			return  # Skip target following entirely
	
	# Handle target following (ONLY if boomerang is disabled or not returning yet)
	match move_using:
		1: # TARGET_NODE
			if follow_target and target_node and is_instance_valid(target_node):
				if steering_degrees < 360:
					# Steering with angle limitation
					var target_dir = (target_node.global_position - global_position).normalized()
					var current_angle = current_direction.angle()
					var target_angle = target_dir.angle()
					var angle_diff = angle_difference(current_angle, target_angle)
					var max_turn = deg_to_rad(steering_degrees) * delta
					var new_angle = current_angle + clamp(angle_diff, -max_turn, max_turn)
					current_direction = Vector2.RIGHT.rotated(new_angle)
				else:
					# Direct targeting (no steering limit)
					current_direction = (target_node.global_position - global_position).normalized()
		0: # TARGET_POSITION
			if follow_target and target_position != original_target_position:
				original_target_position = target_position
				current_direction = (target_position - global_position).normalized()
		# 2: DIRECTION - no update needed, direction stays constant

func angle_difference(from_angle: float, to_angle: float) -> float:
	var diff = fmod(to_angle - from_angle, PI * 2)
	if diff > PI:
		diff -= PI * 2
	elif diff < -PI:
		diff += PI * 2
	return diff

func apply_falloff(delta: float) -> void:
	# Store previous speed for boomerang detection
	var previous_speed = current_speed
	
	# Apply relative falloff (percentage of current speed)
	if relative_falloff > 0:
		# Formula: new_speed = current_speed - (current_speed * relative_falloff * delta * 60)
		# Multiplying by 60 makes it framerate independent (assuming 60 fps baseline)
		current_speed -= current_speed * relative_falloff * delta * 60
	
	# Apply constant falloff (fixed amount per second)
	if constant_falloff > 0:
		current_speed -= constant_falloff * delta * 60
	
	# Clamp speed to prevent negative values
	current_speed = max(0, current_speed)
	
	# Optional: Emit signal or trigger events when speed reaches zero
	if previous_speed > 0 and current_speed <= 0:
		on_speed_zero()
	
func on_speed_zero():
	if destroy_on_no_speed:
		destroy();

func should_bounce(collision_node: Node) -> bool:
	if not bounces_enabled:
		return false
	
	# Check if max bounces reached
	if max_bounces != -1 and current_bounce_count >= max_bounces:
		return false
	
	# Check exception groups (groups that prevent bouncing)
	for group in bounce_exception_groups:
		if collision_node.is_in_group(group):
			return false
	
	# If bounce_only_groups is not empty, only bounce off these groups
	if bounce_only_groups.size() > 0:
		var in_allowed_group = false
		for group in bounce_only_groups:
			if collision_node.is_in_group(group):
				in_allowed_group = true
				break
		if not in_allowed_group:
			return false
	
	return true

func apply_bounce(normal: Vector2, hit_node: Node) -> void:
	# Calculate reflected direction
	var reflected = current_direction - 2 * (current_direction.dot(normal)) * normal
	reflected = reflected.normalized()
	
	# Apply angle variance if any
	if bounce_angle_variance > 0:
		var variance_rad = deg_to_rad(randf_range(-bounce_angle_variance, bounce_angle_variance))
		var cos_variance = cos(variance_rad)
		var sin_variance = sin(variance_rad)
		reflected = Vector2(
			reflected.x * cos_variance - reflected.y * sin_variance,
			reflected.x * sin_variance + reflected.y * cos_variance
		).normalized()
	
	# Store old direction for signal
	var bounce_position = global_position
	
	# Apply changes
	current_direction = reflected
	current_speed *= bounce_damping
	
	# Increment bounce counter
	current_bounce_count += 1
	
	# Emit bounce signal with all relevant information
	emit_signal("bounced", hit_node, current_bounce_count, bounce_position, current_direction, current_speed)

func _on_body_entered(body: Node2D) -> void:
	# Only process collisions on authority
	if not is_authority:
		return
	
	if not can_bounce:
		return
	
	can_bounce = false
	
	# Calculate collision normal (approximate from position difference)
	var normal = (global_position - body.global_position).normalized()
	
	# Check if we should bounce
	if should_bounce(body):
		apply_bounce(normal, body)
	else:
		# Normal hit behavior
		if destroy_when_colliding:
			emit_signal("hit_body", body)
			if body.has_method("take_damage"):
				body.take_damage(damage)
			destroy()

func _on_area_entered(area: Area2D) -> void:
	# Only process collisions on authority
	if not is_authority:
		return
	
	if not can_bounce:
		return
	
	can_bounce = false
	
	# Calculate collision normal from area
	var normal = (global_position - area.global_position).normalized()
	
	# Check if we should bounce
	if should_bounce(area):
		apply_bounce(normal, area)
	else:
		# Normal hit behavior
		if destroy_when_colliding:
			emit_signal("hit_body", area)
			if area.has_method("take_damage"):
				area.take_damage(damage)
			destroy()

@rpc("authority", "call_local", "reliable")
func _rpc_destroy() -> void:
	destroy()

func destroy():
	emit_signal("destroyed", global_position)
	
	if is_authority and is_multiplayer_sync and multiplayer.is_server():
		_rpc_destroy()
	
	if spawn_node_when_destroyed:
		var new_node = spawn_node_when_destroyed.instantiate()
		get_parent().add_child(new_node)
		new_node.global_position = global_position
	if shrink_on_death:
		shrink = true;
	else:
		queue_free();

func _check_cull() -> void:
	var viewport = get_viewport()
	if viewport:
		var rect = viewport.get_visible_rect()
		rect = rect.grow(cull_margin)
		if not rect.has_point(global_position):
			queue_free()
