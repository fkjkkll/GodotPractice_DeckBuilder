class_name Run extends Node

@export var run_startup: RunStartup

const BATTLE = preload("uid://c11h6rkmwtes3")
const BATTLE_REWARD = preload("uid://t82gbql1rcn1")
const CAMPFIRE = preload("uid://cnraxr0mmguay")
const MAP = preload("uid://pbfdscfpn858")
const SHOP = preload("uid://v6lw1kt1q443")
const TREASURE = preload("uid://0yyr2jt7i62v")

@onready var gold_ui: GoldUI = %GoldUI
@onready var current_view: Node = $CurrentView
@onready var deck_button: CardPileOpener = %DeckButton
@onready var deck_view: CardPileView = %DeckView

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
	print("TODO: procedurally generate map")


func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	
	get_tree().paused = false
	var new_view = scene.instantiate()
	current_view.add_child(new_view)
	return new_view


func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_won)
	Events.battle_reward_exited.connect(_change_view.bind(MAP))
	Events.campfire_exited.connect(_change_view.bind(MAP))
	Events.shop_exited.connect(_change_view.bind(MAP))
	Events.treasure_room_exited.connect(_change_view.bind(MAP))
	Events.map_exited.connect(_on_map_exited)
	
	map_button.pressed.connect(_change_view.bind(MAP))
	battle_button.pressed.connect(_change_view.bind(BATTLE))
	shop_button.pressed.connect(_change_view.bind(SHOP))
	treasure_button.pressed.connect(_change_view.bind(TREASURE))
	reward_button.pressed.connect(_change_view.bind(BATTLE_REWARD))
	campfire_button.pressed.connect(_change_view.bind(CAMPFIRE))


func _setup_top_bar() -> void:
	gold_ui.run_stats = stats
	deck_button.card_pile = character.deck
	deck_view.card_pile = character.deck
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))


func _on_battle_won() -> void:
	var reward_scene := _change_view(BATTLE_REWARD) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	# this is temporary code, it will come from real battle encounter data as a dependency
	reward_scene.add_gold_reward(77)
	reward_scene.add_card_reward()


func _on_map_exited() -> void:
	print("TODO: from the map, change view based on room type")
