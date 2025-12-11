extends Node

# Card_related events
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_aim_started(card_ui: CardUI)
signal card_aim_ended(card_ui: CardUI)
signal card_played(card: Card)
signal card_tooltip_requested(icon: Texture, content: String)
signal tooltip_hide_requested

# Player-related events
signal player_hand_drawn		# 玩家抽完本回合的所有卡牌后
signal player_hand_discarded	# 玩家本回合丢弃所有未用到的卡牌后
signal player_turn_ended		# 玩家点击按钮：回合结束
signal player_died
signal player_hit				# 玩家实际受创时发出

# Enemy-related events
signal enemy_action_completed(enemy: Enemy)
signal enemy_turn_ended
signal enemy_died(enemy: Enemy)

# Battle-related events
signal battle_over_screen_requested(text: String, type: BattleOverPanel.Type)
signal battle_won
signal status_tooltip_requested(statuses: Array[Status])

# Map-related events
signal map_exited(room: Room)

# Shop-related events
signal shop_exited
signal shop_relic_bought(relic: Relic, gold_cost: int)
signal shop_card_bought(card: Card, gold_cost: int)
signal shop_entered(shop: Shop)

# Campfire-related event
signal campfire_exited

# Battle Reward-related events
signal battle_reward_exited

# Treasure Room-related events
signal treasure_room_exited(found_relic: Relic)

# Relic-related events
signal relic_tooltip_requested(relic: Relic)
