extends Card


var base_block := 5


func apply_effects(_targets: Array[Node], _modifier: ModifierHandler) -> void:
	var block_effect := BlockEffect.new()
	block_effect.amount = base_block
	block_effect.sound = sound
	block_effect.execute(_targets)
	
	
func get_default_tooltip() -> String:
	return tooltip_text % base_block


func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % base_block
