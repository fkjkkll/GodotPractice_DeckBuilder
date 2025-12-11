class_name CharacterStats extends Stats

@export_group("Visuals")
@export var character_name: String
@export_multiline var descrption: String
@export var portrait: Texture

@export_group("Gameplay Data")
@export var starting_deck: CardPile
@export var draftable_cards: CardPile
@export var cards_per_turn: int
@export var max_mana: int		# 最大法力
@export var starting_relic: Relic

var mana: int: set = _set_mana
var deck: CardPile				# 当前拥有
var discard: CardPile			# 弃牌堆
var draw_pile: CardPile			# 抽牌堆

func _set_mana(value: int) -> void:
	mana = value
	stats_changed.emit()

func reset_mana() -> void:
	mana = max_mana

func take_damage(damage: int) -> void:
	var initial_health := health
	super(damage)
	if initial_health > health:
		Events.player_hit.emit()

func can_play_card(card: Card) -> bool:
	return mana >= card.cost

func create_instance() -> Resource:
	var instance: CharacterStats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	instance.reset_mana()
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
