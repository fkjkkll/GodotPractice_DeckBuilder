class_name CardMenuUI
extends CenterContainer

@export var card: Card: set = _set_card

signal tooltip_requested(card: Card)

const CARD_BASE_STYLEBOX = preload("uid://pbhvsnjifbv0")
const CARD_HOVER_STYLEBOX_TRES = preload("uid://c4bchoun14nm5")

@onready var visuals: CardVisuals = $Visuals

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	card = value
	visuals.card = card

func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		tooltip_requested.emit(card)


func _on_mouse_entered() -> void:
	visuals.panel.set("theme_override_styles/panel", CARD_HOVER_STYLEBOX_TRES)


func _on_mouse_exited() -> void:
	visuals.panel.set("theme_override_styles/panel", CARD_BASE_STYLEBOX)
