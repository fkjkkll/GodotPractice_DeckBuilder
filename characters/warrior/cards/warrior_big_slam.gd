extends Card

const EXPOSED = preload("uid://ctr0k1i1mmf6c")

var base_damage := 4
var exposed_duration := 2

func apply_effects(targets: Array[Node], modifier: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifier.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
	var status_effect := StatusEffect.new()
	var exposed := EXPOSED.duplicate()
	exposed.duration = exposed_duration
	status_effect.status = exposed
	status_effect.execute(targets)
