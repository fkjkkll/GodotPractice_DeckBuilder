class_name Battle extends Node2D

@export var battle_stats: BattleStats
@export var char_stats : CharacterStats
@export var music: AudioStream
@export var relics: RelicHandler

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player

func _ready() -> void:
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.player_died.connect(_on_player_died)


func start_battle() -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	
	battle_ui.char_stats = char_stats
	player.stats = char_stats
	player_handler.relics = relics
	enemy_handler.setup_enemies(battle_stats)
	enemy_handler.reset_enemy_actions()
	
	relics.relics_activated.connect(_on_relics_activated)
	relics.activate_relics_by_type(Relic.Type.START_OF_COMBAT)


func _on_enemy_turn_ended() -> void:
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()


# 监听胜利：敌人全部被消灭后的逻辑
# 危险的信号，场景销毁时也会传递
func _on_enemies_child_order_changed() -> void:
	if is_inside_tree() and enemy_handler.get_child_count() == 0:
		relics.activate_relics_by_type(Relic.Type.END_OF_COMBAT)


func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)


func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_COMBAT:
			player_handler.start_battle(char_stats)
			battle_ui.initialize_card_pile_ui()
		Relic.Type.END_OF_COMBAT:
			Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)
