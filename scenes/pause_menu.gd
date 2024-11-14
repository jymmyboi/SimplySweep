extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func toggle_pause() -> void:
	if visible:
		print("Hiding pause menu")
		get_tree().paused = false
		visible = false
	else:
		print("Showing pause menu")
		get_tree().paused = true
		visible = true

func _on_resume_button_pressed() -> void:
	toggle_pause()
	print("toggle")
	

func _on_restart_button_pressed() -> void:
	print("restart")
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_quit_button_pressed() -> void:
	print("quit")
	get_tree().quit()
