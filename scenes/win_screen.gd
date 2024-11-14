extends Control
@onready var time_label = $TimeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_label.text = str(GameState.time_passed) + "s"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")
