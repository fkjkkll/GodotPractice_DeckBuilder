class_name WinScreen
extends Control

##################################
# 打断循环引用，这里千万不要再preload了
# 否则后面再切换到Run会失败！！！！！
##################################
const MAIN_MENU_UID = "uid://bu0vf8yy1rm0l"
const MESSAGE := "The %s\nis victorious!"

@export var character: CharacterStats : set = set_character

@onready var message: Label = %Message
@onready var character_portrait: TextureRect = %CharacterPortrait


func set_character(new_character: CharacterStats) -> void:
	character = new_character
	message.text = MESSAGE % character.character_name
	character_portrait.texture = character.portrait


func _on_main_menu_button_pressed() -> void:
	##################################
	# 打断循环引用，这里千万不要再preload了
	# 否则后面再切换到Run会失败！！！！！
	##################################
	#get_tree().change_scene_to_packed(MAIN_MENU_PATH)
	get_tree().change_scene_to_file(MAIN_MENU_UID)
