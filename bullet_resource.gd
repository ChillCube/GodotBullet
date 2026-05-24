@icon("res://addons/GodotBullet/icon_bullet.png")
extends Resource
class_name BulletResource

@export var sprite : Texture2D;

@export_group("Collision")
@export var has_collision_shape : bool = true ## Disable if you want to add your own collision shape or if collision is unnecessary
@export var collision_shape_size : float = 0.8 ## Sets how big the collisionshape will be. 1 = same width as sprite, 2 = double the size of sprite, 0.5 = half the size of the sprite
@export var collision_shape_offset : Vector2 = Vector2.ZERO ## allows you to offset the position of the collider from the center of the bullet
@export var collision_mask : int = 1 ## Which physics layers the bullet will collide with
@export var collision_layer : int = 1 ## Which physics layer the bullet belongs to

@export_group("Bouncing")
@export var bounces_enabled : bool = false ## If true, bullet will bounce off surfaces instead of being destroyed
@export var max_bounces : int = 2 ## Maximum number of bounces before the bullet is destroyed (-1 = infinite)
@export var bounce_damping : float = 0.8 ## How much speed is preserved on bounce (1 = no loss, 0 = stop on bounce)
@export var bounce_angle_variance : float = 0 ## Random angle variance on bounce (in degrees, 0 = perfect reflection)
@export var bounce_exception_groups : Array[String] = [] ## Groups that bullet will NOT bounce off (will destroy instead)
@export var bounce_only_groups : Array[String] = [] ## If not empty, ONLY bounce off these groups (others destroy)

@export_group("Speed")
@export var start_speed : float = 100 ## the speed that the bullet starts off with
@export_range(0,1) var relative_falloff : float = 0 ## 0 = no speed will be lost, 1 = bullet will stop instantly, 0.5 = bullet will lose half its speed every frame (Can be combined with constant falloff)
@export var constant_falloff : float = 0 ## will reduce the speed by the given amount each frame. (Can be combined with relative falloff)

@export_subgroup("Boomerang")
@export var boomerang : bool = false ## if enabled, the bullet will curve back to the return target. WARNING: When enabled, target following is ignored
@export_enum("SPEED_RATIO", "DISTANCE") var boomerang_trigger : int = 0 ## What triggers the boomerang to return: SPEED_RATIO (based on remaining speed) or DISTANCE (based on how far it traveled)
@export_range(0, 1) var boomerang_start_at_speed : float = 0.5 ## If using SPEED_RATIO: 1 = returns when it has lost all speed, 0 = returns immediately, 0.5 = returns when half speed remains
@export var boomerang_start_at_distance : float = 100 ## If using DISTANCE: How far the bullet should travel before returning (in pixels)
@export var boomerang_curve_rate : float = 1.5 ## How quickly the bullet curves back (higher = tighter/faster curve, 1 = gentle curve, 2 = sharp curve)
@export_enum("LEFT", "RIGHT", "RANDOM") var boomerang_curve_direction : int = 0 ## Which direction the curve arcs (0=LEFT, 1=RIGHT, 2=RANDOM)
@export var dynamic_return_target : bool = false ## If true, the return target will be checked every frame (useful for moving targets). If false, target is locked at boomerang start
@export var max_return_distance : float = 0 ## OPTIONAL: Maximum distance to return target before destroying (0 = unlimited). Useful for preventing infinite flight

@export_group("Targeting")
@export var follow_target: bool = true ## If enabled, the bullet will keep following the target node or target position
@export_range(0, 360) var steering_degrees: float = 360 ## Maximum angle the bullet can steer each frame towards the target (360 = instant, 0 = no steering)

@export_group("Combat")
@export var damage : float = 10 ## Amount of damage this bullet deals on hit

@export_group("end of life")
@export var destroy_on_no_speed : bool = true ## Decides whether or not the node should be destroyed when its speed reaches 0
@export var destroy_when_colliding : bool = true ## Decides whether or not the node should be destroyed when it collides with something (overridden by bounce if bounce occurs)
@export var destroy_on_return : bool = true ## If true, bullet destroys itself after reaching the return target
@export var shrink_on_death : bool = true
@export var spawn_node_when_destroyed : PackedScene ## Sets a node that is created when the bullet is destroyed. Can be useful if you want to turn the bullet into an item that can be picked up. Leave empty if no node should be created.

@export_group("Performance")
@export var cull_off_screen : bool = true ## If true, bullet will be removed when off screen
@export var cull_margin : float = 100 ## Margin around screen before culling

@export_group("Multiplayer")
@export var is_multiplayer_sync : bool = true ## If true, bullet will sync position across network (auto-detected if multiplayer is active)
