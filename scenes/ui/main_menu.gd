extends Control

@export var run_startup: RunStartup

@onready var continue_button: Button = %Continue

func _ready() -> void:
	get_tree().paused = false
	continue_button.disabled = SaveGame.load_data() == null


func _on_continue_pressed() -> void:
	run_startup.type = RunStartup.Type.CONTINUE_RUN
	get_tree().change_scene_to_file("uid://bbk3xah3s5r6y")


func _on_new_run_pressed() -> void:
	get_tree().change_scene_to_file("uid://det1xi1xcitji")


func _on_exit_pressed() -> void:
	get_tree().quit()
