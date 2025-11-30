extends CharacterBody2D

signal pellet_eaten
signal hit_by_ghost

@export var speed := 50

@onready var pellet_layer := $"../Pellets"
@onready var world := $"../World"
@onready var sprite := $Sprite
var shape_query = PhysicsPointQueryParameters2D.new()

# These help with input buffering / grid movement
var current_direction := Vector2.ZERO
var buffered_direction := Vector2.ZERO

func _ready() -> void:
	sprite.play("right")
	current_direction = Vector2.RIGHT
	shape_query.collide_with_bodies = true
	shape_query.collision_mask = 2
	pass

func get_input():
	if Input.is_action_pressed("ui_left"):
		buffered_direction = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		buffered_direction = Vector2.RIGHT
	elif Input.is_action_pressed("ui_up"):
		buffered_direction = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		buffered_direction = Vector2.DOWN
		
	
	

func _physics_process(_delta: float) -> void:
	# Read player input and store as buffered_direction
	get_input()
	var dir = ""
	if is_equal_approx(current_direction.angle(), 0):
		dir = "right"
	if is_equal_approx(current_direction.angle(), PI/2):
		dir = "down"
	if is_equal_approx(current_direction.angle(), -PI/2):
		dir = "up"
	if is_equal_approx(current_direction.angle(), PI):
		dir = "left"
	# If at an intersection and buffered_direction is free -> switch current_direction to buffered_direction
	if _is_at_intersection(dir) and buffered_direction != current_direction:
		current_direction = buffered_direction
		snap_to_center()
	# Always allow 180° turn immediately (even if not at intersection)
	if buffered_direction.dot(current_direction) == -1:
		current_direction = buffered_direction
	# Set velocity = current_direction * speed and move_and_slide()
	self.velocity = current_direction * speed
	move_and_slide()
	# Update animation to match current_direction (left/right/up/down)
	sprite.play(dir)
	# If Pac-Man leaves maze bounds (check via world/tilemap width) -> wrap to opposite side
	_check_maze_end(dir)
	_check_pellet_pickup()
	_check_ghost_collision()

func _check_pellet_pickup() -> void:
	# Convert Pac-Man's current position to pellet_layer tile/local position
	var current_pos = pellet_layer.local_to_map(global_position)
	# If there is a pellet here -> remove it from pellet_layer (clear tile / queue_free node)
	if pellet_layer.get_cell_source_id(current_pos) != -1:
		pellet_layer.erase_cell(current_pos)
	# emit_signal("pellet_eaten")
		emit_signal("pellet_eaten")

func _check_ghost_collision() -> void:
	#  TODO: If Pac-Man overlaps a Ghost body/area (group "ghost" or by name) -> emit_signal("hit_by_ghost")
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collided_with = collision.get_collider().get("collision_layer")
		#print(collided_with)
		if collided_with == 8:
			emit_signal("hit_by_ghost")

func _can_move_to(_direction: Vector2) -> bool:
	# (helper): Ask world / TileMapLayer if the next tile is free (no wall/collision) (use local_to_map() / map_to_local() on the level TileMap)
	var cell_pos = world.local_to_map(global_position+_direction)
	var world_pos = world.map_to_local(cell_pos)
	shape_query.set_position(world_pos)
	var has_collision: = get_world_2d().direct_space_state.intersect_point(shape_query)
	if has_collision != []:
		return not (world.has_body_rid(has_collision[0]["rid"]))
	return true

func _is_at_intersection(dir: String) -> bool:
	# (helper): Return true when Pac-Man is close enough to tile center to allow turning
	# Convert global -> tilemap-local -> tile coords
	var local_pos: Vector2 = world.to_local(global_position)
	var tile_pos: Vector2i = world.local_to_map(local_pos)

	# Compute the local position of the tile center and convert it back to global
	var tile_center_local: Vector2 = world.map_to_local(tile_pos)
	var tile_center_global: Vector2 = world.to_global(tile_center_local)

	# How close to center we must be to allow turning (tweak as needed)
	var threshold: float = 2.0
	var centered: bool = global_position.distance_to(tile_center_global) < threshold
	if not centered:
		return false
	
	var open_dirs: int = 0
	var dirs: Array = []
	if dir != "right":
		dirs.append(Vector2(8, 0))
	if dir != "left":
		dirs.append(Vector2(-8, 0))
	if dir != "up":
		dirs.append(Vector2(0, -8))
	if dir != "down":
		dirs.append(Vector2(0, 8))
	for d in dirs:
		if _can_move_to(d):
			open_dirs += 1
	return open_dirs >= 2
	
func snap_to_center():
	var local_pos: Vector2 = world.to_local(global_position)
	var tile_pos: Vector2i = world.local_to_map(local_pos)

	# Compute the local position of the tile center and convert it back to global
	var tile_center_local: Vector2 = world.map_to_local(tile_pos)
	var tile_center_global: Vector2 = world.to_global(tile_center_local)
	global_position = tile_center_global

func _check_maze_end(curr_dir):
	var cell_pos = world.local_to_map(global_position)
	if cell_pos[0] == 0 and curr_dir == "left":
		cell_pos[0] = 28
		var new_pos = world.map_to_local(cell_pos)
		global_position[0] = new_pos[0]
	if cell_pos[0] == 28 and curr_dir == "right":
		cell_pos[0] = 0
		var new_pos = world.map_to_local(cell_pos)
		global_position[0] = new_pos[0]
