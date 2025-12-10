class_name MapRoom extends Area2D

signal selected(room: Room)

const ICONS := {
	Room.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Room.Type.MONSTER: [preload("uid://bfvi02kojsa00"), Vector2.ONE],
	Room.Type.TREASURE: [preload("uid://hva3iy5hon7a"), Vector2.ONE],
	Room.Type.CAMPFIRE: [preload("uid://dmnh5xxe2xne0"), Vector2(0.6, 0.6)],
	Room.Type.SHOP: [preload("uid://dhmtctwb5ymhc"), Vector2(0.6, 0.6)],
	Room.Type.BOSS: [preload("uid://bxgrktox5it82"), Vector2(1.25, 1.25)],
}

@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D
@onready var line_2d: Line2D = $Visuals/Line2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var available := false: set = _set_available
var room: Room: set = _set_room


func _set_available(value: bool) -> void:
	available = value
	if available:
		animation_player.play("highlight")
	elif not room.selected:
		animation_player.play("RESET")


func _set_room(value: Room) -> void:
	room = value
	position = room.position
	line_2d.rotation_degrees = randi_range(0, 360)
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]


func show_selected() -> void:
	#line_2d.modulate = Color.WHITE
	animation_player.play("select")


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not available or not event.is_action_pressed("left_mouse"):
		return
	room.selected = true
	animation_player.play("select")


# Called by the AnimationPlayer when the "select" animation finishes
func _on_map_room_selected() -> void:
	selected.emit(room)
