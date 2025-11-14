extends Node2D

@onready var game_over_screen = $"Game Over Screen"
@onready var player := $PacMan
@onready var pellet_layer := $Pellets

var total_pellets := 0
var pellets_eaten := 0

func _ready():
	# TODO: Count how many pellets exist at start (from pellet_layer tiles) and store in total_pellets
	player.connect("pellet_eaten", _on_pellet_eaten)
	# TODO: player.connect("hit_by_ghost", on_lost)
	pass

func _on_pellet_eaten():
	# TODO: If Pac-Man has eaten all pellects, fire on_won
	pass

func on_lost():
	game_over_screen.show_game_over("You Lost!")

func on_won():
	game_over_screen.show_game_over("You Won!")
