extends Relic


func activate_relic(owner: RelicUI) -> void:
	#_add_mana(owner)
	# 由于遗物激活后，玩家回合开始前会重置法力值
	# 因此此处的触发会被覆盖
	# 这里的解决方法是等法力值重置后，抽牌结束后再触发
	# 算是一种取巧的方式
	# CONNECT_ONE_SHOT保证只触发一次once
	Events.player_hand_drawn.connect(_add_mana.bind(owner), CONNECT_ONE_SHOT)


func _add_mana(owner: RelicUI) -> void:
	owner.flash()
	var player := owner.get_tree().get_first_node_in_group("player") as Player
	if player:
		player.stats.mana += 1
