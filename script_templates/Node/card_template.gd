# meta-name: Card
# meta-description: What happens when a card is played.
extends Card


func apply_effects(targets: Array[Node], _modifier: ModifierHandler) -> void:
	print("My awesome card has been played!")
	print("Targets: %s" % targets)
