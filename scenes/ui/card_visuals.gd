class_name CardVisuals extends Control

@export var card: Card : set = _set_card

@onready var panel: Panel = $Panel
@onready var cost: Label = $Cost
@onready var icon: TextureRect = $Icon
@onready var rarity: TextureRect = $Rarity

func _set_card(value: Card) -> void:
	# 因为导出变量可能在项目运行时节点尚未加入场景树前被赋值
	if not is_node_ready():
		await ready
	card = value
	cost.text = str(card.cost)
	icon.texture = card.icon
	rarity.modulate = Card.RARITY_COLORS[card.rarity]
