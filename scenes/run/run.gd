class_name Run extends Node

@export var run_startup: RunStartup

const BATTLE = preload("uid://c11h6rkmwtes3")
const BATTLE_REWARD = preload("uid://t82gbql1rcn1")
const CAMPFIRE = preload("uid://cnraxr0mmguay")
const SHOP = preload("uid://v6lw1kt1q443")
const TREASURE = preload("uid://0yyr2jt7i62v")
const WIN_SCREEN = preload("uid://tdhjrs5j5h33")
const MAIN_MENU_UID = "uid://bu0vf8yy1rm0l"

@onready var map: Map = $Map
@onready var health_ui: HealthUI = %HealthUI
@onready var gold_ui: GoldUI = %GoldUI
@onready var current_view: Node = $CurrentView
@onready var deck_button: CardPileOpener = %DeckButton
@onready var deck_view: CardPileView = %DeckView
@onready var relic_handler: RelicHandler = %RelicHandler
@onready var relic_tool_tip: RelicTooltip = %RelicToolTip
@onready var pause_menu: PauseMenu = $PauseMenu

@onready var map_button: Button = %MapButton
@onready var battle_button: Button = %BattleButton
@onready var shop_button: Button = %ShopButton
@onready var treasure_button: Button = %TreasureButton
@onready var reward_button: Button = %RewardButton
@onready var campfire_button: Button = %CampfireButton

var stats: RunStats
var character: CharacterStats
var save_data: SaveGame


func _ready() -> void:
	if not run_startup:
		return
	
	pause_menu.save_and_quit.connect(
		func(): get_tree().change_scene_to_file(MAIN_MENU_UID)
	)
	
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			character = run_startup.picked_character.create_instance()
			_start_run()
		RunStartup.Type.CONTINUE_RUN:
			_load_run()


# 作弊：方便测试
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat"):
		get_tree().call_group("enemies", "queue_free")


func _start_run() -> void:
	stats = RunStats.new()
	_setup_event_connections()
	_setup_top_bar()
	map.generate_new_map()
	map.unlock_floor(0)
	save_data = SaveGame.new()
	_save_run(true)


func _save_run(was_on_map: bool) -> void:
	save_data.rng_seed = RNG.instance.seed
	save_data.rng_state = RNG.instance.state
	save_data.run_stats = stats
	save_data.char_stats = character
	save_data.current_deck = character.deck
	save_data.current_health = character.health
	save_data.relics = relic_handler.get_all_relics()
	save_data.last_room = map.last_room
	save_data.map_data = map.map_data.duplicate()
	save_data.floors_climbed = map.floors_climbed
	save_data.was_on_map = was_on_map
	save_data.save_data()


func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data, "Couldn't load last save")
	
	RNG.set_from_save_data(save_data.rng_seed, save_data.rng_state)
	stats = save_data.run_stats
	character = save_data.char_stats
	character.deck = save_data.current_deck
	character.health = save_data.current_health
	relic_handler.add_relics(save_data.relics)
	_setup_top_bar()
	_setup_event_connections()
	
	map.load_map(save_data.map_data, save_data.floors_climbed, save_data.last_room)
	if save_data.last_room and not save_data.was_on_map:
		_on_map_exited(save_data.last_room)


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
	_save_run(true)


func _show_regular_battle_rewards() -> void:
	var reward_scene := _change_view(BATTLE_REWARD) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.add_gold_reward(map.last_room.battle_stats.roll_gold_reward())
	reward_scene.add_card_reward()


func _setup_event_connections() -> void:
	Events.battle_reward_exited.connect(show_map)
	Events.campfire_exited.connect(show_map)
	Events.shop_exited.connect(show_map)
	Events.battle_won.connect(_on_battle_won)
	Events.map_exited.connect(_on_map_exited)
	Events.treasure_room_exited.connect(_on_treasure_room_existed)
	
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
	if map.floors_climbed == MapGenerator.FLOOR:
		var win_screen := _change_view(WIN_SCREEN) as WinScreen
		win_screen.character = character
		SaveGame.delete_data()
	else:
		_show_regular_battle_rewards()


func _on_battle_room_entered(room: Room) -> void:
	var battle_scene: Battle = _change_view(BATTLE) as Battle
	battle_scene.char_stats = character
	battle_scene.battle_stats = room.battle_stats
	battle_scene.relics = relic_handler
	battle_scene.start_battle()


func _on_campfire_entered() -> void:
	var campfire := _change_view(CAMPFIRE) as Campfire
	campfire.char_stats = character


func _on_shop_entered() -> void:
	var shop := _change_view(SHOP) as Shop
	shop.char_stats = character
	shop.run_stats = stats
	shop.relic_handler = relic_handler
	Events.shop_entered.emit(shop) # populate_shop前完成
	shop.populate_shop()


func _on_treasure_room_entered() -> void:
	var treasure_scene := _change_view(TREASURE) as Treasure
	treasure_scene.relic_handler = relic_handler
	treasure_scene.char_stats = character
	treasure_scene.generate_relic()


func _on_treasure_room_existed(relic: Relic) -> void:
	var reward_scene := _change_view(BATTLE_REWARD) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.relic_handler = relic_handler
	reward_scene.add_relic_reward(relic)


func _on_map_exited(room: Room) -> void:
	_save_run(false)
	match room.type:
		Room.Type.MONSTER:
			_on_battle_room_entered(room)
		Room.Type.TREASURE:
			_on_treasure_room_entered()
		Room.Type.CAMPFIRE:
			_on_campfire_entered()
		Room.Type.SHOP:
			_on_shop_entered()
		Room.Type.BOSS:
			_on_battle_room_entered(room)
