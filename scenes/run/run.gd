class_name Run extends Node

@export var run_startup: RunStartup

const BATTLE = preload("uid://c11h6rkmwtes3")
const BATTLE_REWARD = preload("uid://t82gbql1rcn1")
const CAMPFIRE = preload("uid://cnraxr0mmguay")
const SHOP = preload("uid://v6lw1kt1q443")
const TREASURE = preload("uid://0yyr2jt7i62v")

@onready var map: Map = $Map
@onready var health_ui: HealthUI = %HealthUI
@onready var gold_ui: GoldUI = %GoldUI
@onready var current_view: Node = $CurrentView
@onready var deck_button: CardPileOpener = %DeckButton
@onready var deck_view: CardPileView = %DeckView
@onready var relic_handler: RelicHandler = %RelicHandler
@onready var relic_tool_tip: RelicTooltip = %RelicToolTip

@onready var map_button: Button = %MapButton
@onready var battle_button: Button = %BattleButton
@onready var shop_button: Button = %ShopButton
@onready var treasure_button: Button = %TreasureButton
@onready var reward_button: Button = %RewardButton
@onready var campfire_button: Button = %CampfireButton

var stats: RunStats
var character: CharacterStats

func _ready() -> void:
	if not run_startup:
		return
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			character = run_startup.picked_character.create_instance()
			_start_run()
		RunStartup.Type.CONTINUE_RUN:
			print("TODO: load previous Run")


func _start_run() -> void:
	stats = RunStats.new()
	_setup_event_connections()
	_setup_top_bar()
	map.generate_new_map()
	map.unlock_floor(0)


func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	
	get_tree().paused = false
	var new_view = scene.instantiate()
	current_view.add_child(new_view)
	
	map.hide_map()
	return new_view


func show_map() -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	map.show_map()
	map.unlock_next_rooms()


func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_won)
	Events.battle_reward_exited.connect(show_map)
	Events.campfire_exited.connect(show_map)
	Events.shop_exited.connect(show_map)
	Events.treasure_room_exited.connect(show_map)
	Events.map_exited.connect(_on_map_exited)
	
	map_button.pressed.connect(show_map)
	battle_button.pressed.connect(_change_view.bind(BATTLE))
	shop_button.pressed.connect(_change_view.bind(SHOP))
	treasure_button.pressed.connect(_change_view.bind(TREASURE))
	reward_button.pressed.connect(_change_view.bind(BATTLE_REWARD))
	campfire_button.pressed.connect(_change_view.bind(CAMPFIRE))


func _setup_top_bar() -> void:
	character.stats_changed.connect(health_ui.update_stats.bind(character))
	health_ui.update_stats(character)
	gold_ui.run_stats = stats
	
	relic_handler.add_relic(character.starting_relic)
	Events.relic_tooltip_requested.connect(relic_tool_tip.show_tooltip)
	
	deck_button.card_pile = character.deck
	deck_view.card_pile = character.deck
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))


func _on_battle_won() -> void:
	var reward_scene := _change_view(BATTLE_REWARD) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.add_gold_reward(map.last_room.battle_stats.roll_gold_reward())
	reward_scene.add_card_reward()


func _on_battle_room_entered(room: Room) -> void:
	var battle_scene: Battle = _change_view(BATTLE) as Battle
	battle_scene.char_stats = character
	battle_scene.battle_stats = room.battle_stats
	battle_scene.relics = relic_handler
	battle_scene.start_battle()


func _on_campfire_entered() -> void:
	var campfire := _change_view(CAMPFIRE) as Campfire
	campfire.char_stats = character


func _on_map_exited(room: Room) -> void:
	match room.type:
		Room.Type.MONSTER:
			_on_battle_room_entered(room)
		Room.Type.TREASURE:
			_change_view(TREASURE)
		Room.Type.CAMPFIRE:
			_on_campfire_entered()
		Room.Type.SHOP:
			_change_view(SHOP)
		Room.Type.BOSS:
			_on_battle_room_entered(room)
