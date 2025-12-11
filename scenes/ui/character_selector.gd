extends Control

@export var run_startup: RunStartup

const RUN_SCENE = preload("uid://bbk3xah3s5r6y")

const WARRIOR = preload("uid://cdmqf0g2t6j1v")
const WIZARD = preload("uid://dpxucvrcbytf")
const ASSASSIN = preload("uid://blw2kgnt4fxn2")

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var character_portrait: TextureRect = %CharacterPortrait

var current_character: CharacterStats: set = _set_current_character

func _ready() -> void:
	_set_current_character(WARRIOR)


func _set_current_character(value: CharacterStats) -> void:
	current_character = value
	title.text = current_character.character_name
	description.text = current_character.descrption
	character_portrait.texture = current_character.portrait


func _on_start_button_pressed() -> void:
	print("Start new run with %s" % current_character.character_name)
	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.picked_character = current_character
	get_tree().change_scene_to_packed(RUN_SCENE)


func _on_warrior_button_pressed() -> void:
	current_character = WARRIOR


func _on_wizard_button_pressed() -> void:
	current_character = WIZARD


func _on_assassin_button_pressed() -> void:
	current_character = ASSASSIN
