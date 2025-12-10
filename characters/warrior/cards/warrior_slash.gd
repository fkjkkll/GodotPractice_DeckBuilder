extends Card

var base_damage := 4

func apply_effects(targets: Array[Node], modifier: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifier.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
