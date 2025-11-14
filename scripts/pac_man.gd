extends CharacterBody2D

signal pellet_eaten
signal hit_by_ghost

@export var speed := 200

@onready var pellet_layer := $"../Pellets"
@onready var world := $"../World"
@onready var sprite := $Sprite

# These help with input buffering / grid movement
var current_direction := Vector2.ZERO
var buffered_direction := Vector2.ZERO

func _ready() -> void:
	sprite.play("up")
	pass

func get_input() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _physics_process(_delta: float) -> void:
	# TODO: Read player input and store as buffered_direction
	# TODO: If at an intersection and buffered_direction is free -> switch current_direction to buffered_direction
	# TODO: Always allow 180° turn immediately (even if not at intersection)
	# TODO: Set velocity = current_direction * speed and move_and_slide()
	# TODO: Update animation to match current_direction (left/right/up/down)
	# TODO: If Pac-Man leaves maze bounds (check via world/tilemap width) -> wrap to opposite side
	_check_pellet_pickup()
	_check_ghost_collision()

func _check_pellet_pickup() -> void:
	# TODO: Convert Pac-Man's current position to pellet_layer tile/local position
	# TODO: If there is a pellet here -> remove it from pellet_layer (clear tile / queue_free node)
	# TODO: emit_signal("pellet_eaten")
	pass

func _check_ghost_collision() -> void:
	# TODO: If Pac-Man overlaps a Ghost body/area (group "ghost" or by name) -> emit_signal("hit_by_ghost")
	pass

func _can_move_to(_direction: Vector2) -> bool:
	# TODO (helper): Ask world / TileMapLayer if the next tile is free (no wall/collision) (use local_to_map() / map_to_local() on the level TileMap)
	return true

func _is_at_intersection() -> bool:
	# TODO (helper): Return true when Pac-Man is close enough to tile center to allow turning
	return true
