# GodotBullet API Reference
Generated: 2026-05-23

A simple button node for godot

## Class: Projectile2D
**Inherits:** [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html)


### ⚙️ Inspector Variables (Exported)
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **has_collision_shape** | `bool` | `true` | Disable if you want to add your own collision shape or if collision is unnecessary |
| **collision_shape_size** | `float` | `0.8` | Sets how big the collisionshape will be. 1 = same width as sprite, 2 = double the size of sprite, 0.5 = half the size of the sprite |
| **collision_shape_offset** | `Vector2` | `Vector2.ZERO` | allows you to offset the position of the collider from the center of the bullet |
| **collision_mask** | `int` | `1` | Which physics layers the bullet will collide with |
| **collision_layer** | `int` | `1` | Which physics layer the bullet belongs to |
| **bounces_enabled** | `bool` | `false` | If true, bullet will bounce off surfaces instead of being destroyed |
| **max_bounces** | `int` | `2` | Maximum number of bounces before the bullet is destroyed (-1 = infinite) |
| **bounce_damping** | `float` | `0.8` | How much speed is preserved on bounce (1 = no loss, 0 = stop on bounce) |
| **bounce_angle_variance** | `float` | `0` | Random angle variance on bounce (in degrees, 0 = perfect reflection) |
| **bounce_exception_groups** | `Array[String]` | `[]` | Groups that bullet will NOT bounce off (will destroy instead) |
| **bounce_only_groups** | `Array[String]` | `[]` | If not empty, ONLY bounce off these groups (others destroy) |
| **start_speed** | `float` | `100` | the speed that the bullet starts off with |
| **relative_falloff** | `float` | `0` | 0 = no speed will be lost, 1 = bullet will stop instantly, 0.5 = bullet will lose half its speed every frame (Can be combined with constant falloff) |
| **constant_falloff** | `float` | `0` | will reduce the speed by the given amount each frame. (Can be combined with relative falloff) |
| **boomerang** | `bool` | `false` | if enabled, the bullet will curve back to the return target. WARNING: When enabled, target following is ignored |
| **boomerang_trigger** | `int` | `0` | What triggers the boomerang to return: SPEED_RATIO (based on remaining speed) or DISTANCE (based on how far it traveled) |
| **boomerang_start_at_speed** | `float` | `0.5` | If using SPEED_RATIO: 1 = returns when it has lost all speed, 0 = returns immediately, 0.5 = returns when half speed remains |
| **boomerang_start_at_distance** | `float` | `100` | If using DISTANCE: How far the bullet should travel before returning (in pixels) |
| **boomerang_curve_rate** | `float` | `1.5` | How quickly the bullet curves back (higher = tighter/faster curve, 1 = gentle curve, 2 = sharp curve) |
| **boomerang_curve_direction** | `int` | `0` | Which direction the curve arcs (0=LEFT, 1=RIGHT, 2=RANDOM) |
| **boomerang_return_target** | `Node2D` | `null` | OPTIONAL: Set a node for the boomerang to return to (like the player). If null, returns to original firing position |
| **dynamic_return_target** | `bool` | `false` | If true, the return target will be checked every frame (useful for moving targets). If false, target is locked at boomerang start |
| **max_return_distance** | `float` | `0` | OPTIONAL: Maximum distance to return target before destroying (0 = unlimited). Useful for preventing infinite flight |
| **move_using** | `int` | `0` | decides whether the bullet will move according to a direction or according to a target. NOTE: If boomerang is enabled, this is ignored after returning starts |
| **direction** | `float` | `-` | decides what direction the bullet should move in |
| **target_position** | `Vector2;` | `-` | decides what target the bullet should move towards |
| **target_node** | `Node2D;` | `-` | set the node that the bullet is meant to target |
| **follow_target** | `bool` | `true` | if enabled, the bullet will keep following that target |
| **steering_degrees** | `float` | `360` | Sets the maximum angle that the bullet can steer each frame towards the target, at 360 the bullet will go directly to the player, at 0 the bullet will go straightforward. Anything between, the bullet will try to curve towards the target |
| **damage** | `float` | `10` | Amount of damage this bullet deals on hit |
| **destroy_on_no_speed** | `bool` | `true` | Decides whether or not the node should be destroyed when its speed reaches 0 |
| **destroy_when_colliding** | `bool` | `true` | Decides whether or not the node should be destroyed when it collides with something (overridden by bounce if bounce occurs) |
| **destroy_on_return** | `bool` | `true` | If true, bullet destroys itself after reaching the return target |
| **spawn_node_when_destroyed** | `PackedScene;` | `-` | Sets a node that is created when the bullet is destroyed. Can be useful if you want to turn the bullet into an item that can be picked up. Leave empty if no node should be created. |
| **cull_off_screen** | `bool` | `true` | If true, bullet will be removed when off screen |
| **cull_margin** | `float` | `100` | Margin around screen before culling |
| **is_multiplayer_sync** | `bool` | `true` | If true, bullet will sync position across network (auto-detected if multiplayer is active) |

### 💾 Class Variables (Standard)
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **locked_return_target_position** | `Vector2` | `Vector2.ZERO` | Locked position if dynamic_return_target is false |
| **original_forward_direction** | `Vector2` | `Vector2.RIGHT` | Store the original direction for curve calculation |
| **distance_traveled** | `float` | `0` | Tracks total distance traveled for distance-based trigger |
| **current_bounce_count** | `int` | `0` | Tracks how many times bullet has bounced |
| **can_bounce** | `bool` | `true` | Used to prevent multiple bounces from same collision |
| **is_authority** | `bool` | `true` | Whether this instance controls the bullet (server or single player) |
| **last_synced_position** | `Vector2` | `Vector2.ZERO` | Last position that was synced |
| **sync_timer** | `float` | `0` | Timer for network sync |
| **sync_interval** | `float` | `0.05` | How often to sync position (20 times per second) |

### 🔔 Signals
| Signal | Arguments | Description |
| :--- | :--- | :--- |
| **boomerang_returned** | `` |  Emitted when the boomerang reaches its return target |
| **bounced** | `hit_node : Node`<br>`bounce_count : int`<br>`bounce_position : Vector2`<br>`new_direction : Vector2`<br>`current_speed : float` |  Emitted when bullet bounces - provides hit node, bounce count, position, new direction, and remaining speed |

---

