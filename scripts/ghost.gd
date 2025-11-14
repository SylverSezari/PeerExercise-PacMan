extends CharacterBody2D

@export var speed := 160
@export var chase_duration_sec := 5.0
@export var chase_interval_min_sec := 5.0
@export var chase_interval_max_sec := 15.0

@onready var sprite := $Sprite
@onready var player := $"../PacMan"
@onready var world := $"../World"

var current_direction := Vector2.ZERO
var is_chasing := false

func _ready() -> void:
	randomize()
	sprite.play("up")
	pass

func _physics_process(_delta: float) -> void:
	if is_chasing:
		# TODO: Pick chasing direction
		pass
	else:
		# TODO: Pick random direction
		pass
	# TODO: Update animation to match movement direction
	pass

func _enter_chase_mode() -> void:
	# ACCEPTANCE: Ghost chase behavior (5 seconds)
	# TODO: set is_chasing = true and after chase_duration_sec -> call _exit_chase_mode()
	pass

func _exit_chase_mode() -> void:
	# TODO: set is_chasing = false and schedule next call to _enter_chase_mode() with random wait between 5–15 seconds
	pass

func _pick_random_direction() -> Vector2:
	# TODO: from [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN], pick one at random
	# TODO: discard blocked directions using world / TileMap
	return Vector2.ZERO

func _pick_chasing_direction() -> Vector2:
	# TODO: compare ghost tile position to player's tile position choose horizontal/vertical step that reduces the distance or use A* directly
	return Vector2.ZERO

func _is_at_intersection() -> bool:
	# TODO (helper): true when ghost can choose a new direction (no wall on at least 2 perpendicular directions)
	return true
