extends CanvasLayer

@onready var label: Label = $Background/Label
@onready var button: Button = $Background/Button

func _ready():
	visible = false
	button.pressed.connect(_on_restart_pressed)

func show_game_over(text: String):
	label.text = text
	visible = true

func _on_restart_pressed():
	get_tree().reload_current_scene()
