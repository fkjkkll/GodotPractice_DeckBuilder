extends Card

const TRUE_STRENGTH_FORM = preload("uid://bhtfqv34p73pb")

func apply_effects(targets: Array[Node]) -> void:
	var status_effect := StatusEffect.new()
	var true_strength := TRUE_STRENGTH_FORM.duplicate()
	status_effect.status = true_strength
	status_effect.execute(targets)
