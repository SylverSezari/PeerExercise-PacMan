extends CharacterBody2D

@export var speed := 50
@export var chase_duration_sec := 5
@export var chase_interval_min_sec := 5
@export var chase_interval_max_sec := 15

@onready var sprite := $Sprite
@onready var player := $"../PacMan"
@onready var world := $"../World"
@onready var timer := $"Timer"

var shape_query = PhysicsPointQueryParameters2D.new()

var current_direction := Vector2.ZERO
var directions := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
var is_chasing := false

func _ready() -> void:
	randomize()
	shape_query.collide_with_bodies = true
	shape_query.collision_mask = 2
	sprite.play("up")
	current_direction = Vector2.UP
	timer.start(10)

func _physics_process(_delta: float) -> void:
	self.velocity = current_direction * speed
	move_and_slide()
	_check_maze_end()

func _enter_chase_mode() -> void:
	# ACCEPTANCE: Ghost chase behavior (5 seconds)
	# set is_chasing = true and after chase_duration_sec -> call _exit_chase_mode()
	print("Enter chasing mode")
	is_chasing = true
	timer.start(chase_duration_sec)

func _exit_chase_mode() -> void:
	# set is_chasing = false and schedule next call to _enter_chase_mode() with random wait between 5–15 seconds
	print("Exit chasing mode")
	is_chasing = false
	var num = randi_range(chase_interval_min_sec, chase_interval_max_sec)
	timer.start(num)

func _pick_random_direction(valid_directions) -> Vector2:
	# From valid_directions, pick one at random
	var rand = randi() % valid_directions.size()
	var direction = valid_directions[rand]
	return  direction

func _pick_chasing_direction() -> Vector2:
	# Compare ghost tile position to player's tile position choose horizontal/vertical step that reduces the distance or use A* directly
	var player_tile_position = world.local_to_map(player.global_position)
	
	var best_distance = INF
	var best_direction = Vector2.ZERO
	
	for direction in directions:
		
		if _check_direction(direction):
			var next_tile: Vector2i = world.local_to_map(global_position + (direction * 8))
			var distance = next_tile.distance_to(player_tile_position)
			
			if distance < best_distance:
				best_distance = distance
				best_direction = direction
		
	return best_direction

func _is_at_intersection() -> bool:
	# True when ghost can choose a new direction (no wall on at least 2 perpendicular directions), also sets new direction

	var local_pos: Vector2 = world.to_local(global_position)
	var tile_pos: Vector2i = world.local_to_map(local_pos)

	# Compute the local position of the tile center and convert it back to global
	var tile_center_local: Vector2 = world.map_to_local(tile_pos)
	var tile_center_global: Vector2 = world.to_global(tile_center_local)

	# How close to center we must be to allow turning (tweak as needed)
	var threshold: float = 3.0
	var centered: bool = global_position.distance_to(tile_center_global) < threshold
	if not centered:
		return false
	
	if is_chasing:
		current_direction = _pick_chasing_direction()
		return true
	else:
		var valid_directions = []
		for direction in directions:
			if _check_direction(direction):
				valid_directions.append(direction)
		if valid_directions.size() >= 3:
			current_direction = _pick_random_direction(valid_directions)
			return true
		elif valid_directions.size() == 2 and current_direction not in valid_directions:
			current_direction = _pick_random_direction(valid_directions)
			return true
		elif valid_directions.size() == 1:
			current_direction = valid_directions[0]
			return true
		return false

func _check_direction(direction: Vector2):
	var cell_pos = world.local_to_map(global_position+(direction*8))
	var world_pos = world.map_to_local(cell_pos)
	shape_query.set_position(world_pos)
	var has_collision: = get_world_2d().direct_space_state.intersect_point(shape_query)
	if has_collision != []:
		return not (world.has_body_rid(has_collision[0]["rid"]))
	return true
	
func snap_to_center():
	var local_pos: Vector2 = world.to_local(global_position)
	var tile_pos: Vector2i = world.local_to_map(local_pos)

	# Compute the local position of the tile center and convert it back to global
	var tile_center_local: Vector2 = world.map_to_local(tile_pos)
	var tile_center_global: Vector2 = world.to_global(tile_center_local)
	global_position = tile_center_global
	
func _check_maze_end():
	var cell_pos = world.local_to_map(global_position)
	if cell_pos[0] == 0 and current_direction == Vector2.LEFT:
		cell_pos[0] = 28
		var new_pos = world.map_to_local(cell_pos)
		global_position[0] = new_pos[0]
	if cell_pos[0] == 28 and current_direction == Vector2.RIGHT:
		cell_pos[0] = 0
		var new_pos = world.map_to_local(cell_pos)
		global_position[0] = new_pos[0]


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_class("TileMapLayer"):
		var dir = ""
		var new_direction = _is_at_intersection()
		# Update animation to match movement direction
		if new_direction:
			snap_to_center()
			if is_equal_approx(current_direction.angle(), 0):
				dir = "right"
			if is_equal_approx(current_direction.angle(), PI/2):
				dir = "down"
			if is_equal_approx(current_direction.angle(), -PI/2):
				dir = "up"
			if is_equal_approx(current_direction.angle(), PI):
				dir = "left"
			sprite.play(dir)


func _on_timer_timeout() -> void:
	if is_chasing:
		_exit_chase_mode()
	else:
		_enter_chase_mode()
