extends Node2D

@onready var game_over_screen = $"Game Over Screen"
@onready var player := $PacMan
@onready var pellet_layer := $Pellets

var total_pellets := 0
var pellets_eaten := 0

func _ready():
	# Count how many pellets exist at start (from pellet_layer tiles) and store in total_pellets
	total_pellets = count_pellets()
	print(total_pellets)
	player.connect("pellet_eaten", _on_pellet_eaten)
	# player.connect("hit_by_ghost", on_lost)
	player.connect("hit_by_ghost", on_lost)
	pass

func _on_pellet_eaten():
	# If Pac-Man has eaten all pellects, fire on_won
	pellets_eaten += 1
	if total_pellets == pellets_eaten:
		on_won()

func on_lost():
	game_over_screen.show_game_over("You Lost!")

func on_won():
	game_over_screen.show_game_over("You Won!")

func count_pellets() -> int:
	var count: int = 0

	# Get the bounding rect of all used tiles
	var used_rect = pellet_layer.get_used_rect()

	# Loop through every tile in that region
	for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			var tile_pos := Vector2i(x, y)
			var tile_data = pellet_layer.get_cell_tile_data(tile_pos)

			if tile_data != null:
				count += 1

	return count
