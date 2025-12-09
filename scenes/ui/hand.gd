class_name Hand
extends HBoxContainer

@export var char_stats: CharacterStats
const CARD_UI = preload("uid://ckb4vtimavoej")

func add_card(card: Card) -> void:
	var new_card_ui := CARD_UI.instantiate() as CardUI
	add_child(new_card_ui)
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.card = card
	new_card_ui.parent = self
	new_card_ui.char_stats = char_stats

func discard_card(card: CardUI) -> void:
	card.queue_free()

func disable_hand() -> void:
	for card: CardUI in get_children():
		card.disable = true
	
func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
	var new_index := clampi(child.original_index, 0, get_child_count())
	move_child.call_deferred(child, new_index)				# 确保发生在帧末尾
