class_name CardUI extends Control

@warning_ignore("unused_signal")
signal reparent_requested(which_card_ui: CardUI)

const CARD_BASE_STYLEBOX := preload("uid://pbhvsnjifbv0")
const CARD_DRAGGING_STYLEBOX := preload("uid://djq0e0hgbywgv")
const CARD_HOVER_STYLEBOX_TRES := preload("uid://c4bchoun14nm5")

@export var card: Card: set = _set_card
@export var char_stats : CharacterStats : set = _set_char_stats

@onready var card_visuals: CardVisuals = $CardVisuals
@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
@onready var targets: Array[Node] = []		# 卡牌当前接触到的合法碰撞体

var original_index := 0
var parent: Control
var tween: Tween
var playable := true : set = _set_playable	# 能量不足时
var disable := false						# 拖动其他卡牌时，当前卡牌状态

func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)

func play() -> void:
	if not card:
		return
	card.play(targets, char_stats)
	queue_free()

# Node类继承默认回调
func _ready() -> void:
	card_state_machine.init(self)
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_existed)
	drop_point_detector.area_entered.connect(_on_drop_point_detector_area_entered)
	drop_point_detector.area_exited.connect(_on_drop_point_detector_area_existed)
	Events.card_aim_started.connect(_on_card_drag_or_aiming_started)
	Events.card_aim_ended.connect(_on_card_drag_or_aiming_ended)
	Events.card_drag_started.connect(_on_card_drag_or_aiming_started)
	Events.card_drag_ended.connect(_on_card_drag_or_aiming_ended)

# Node类继承默认回调
func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

# 需要手动注册
func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)

# 需要手动注册
func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()

# 需要手动注册
func _on_mouse_existed() -> void:
	card_state_machine.on_mouse_existed()

func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)
	
func _on_drop_point_detector_area_existed(area: Area2D) -> void:
	targets.erase(area)

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	card = value
	card_visuals.card = card

func _set_playable(value: bool) -> void:
	playable = value
	if not playable:
		card_visuals.cost.add_theme_color_override("font_color", Color.RED)
		card_visuals.icon.modulate = Color(1.0, 1.0, 1.0, 0.5)
	else:
		card_visuals.cost.remove_theme_color_override("font_color")
		card_visuals.icon.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	char_stats.stats_changed.connect(_on_char_stats_changed)

func _on_card_drag_or_aiming_started(usedCard: CardUI) -> void:
	if usedCard == self:
		return
	disable = true

func _on_card_drag_or_aiming_ended(_usedCard: CardUI) -> void:
	disable = false
	playable = char_stats.can_play_card(card)

func _on_char_stats_changed() -> void:
	playable = char_stats.can_play_card(card)
