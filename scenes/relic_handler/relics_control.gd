class_name RelicsControl
extends Control

const RELICS_PER_PAGE := 5
const TWEEN_SCROLL_DURATION := 0.2

@onready var left_button: TextureButton = %LeftButton
@onready var right_button: TextureButton = %RightButton


@onready var relics: HBoxContainer = %Relics
@onready var page_width = self.custom_minimum_size.x + %Relics.get("theme_override_constants/separation")

var num_of_relics := 0
var current_page := 1
var max_page := 0
var tween: Tween
var relics_position: float


func _ready() -> void:
	relics_position = relics.position.x
	
	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)

	for relic_ui: RelicUI in relics.get_children():
		relic_ui.free()
		#relic_ui.queue_free() # FIXME

	relics.child_order_changed.connect(_on_relics_child_order_changed)


func update() -> void:
	# 由于监听了child_order_changed，当场景销毁释放的时候，从场景布局可以看到：right_button
	# 是第一个就要释放的节点，随后，当释放第一个遗物时，触发了事件回调，会执行update，此时由于
	# right_button按钮已经释放掉了，所以会有null指针报错，其实只需要判断right_button就可以
	#if not is_instance_valid(left_button) or not is_instance_valid(right_button):
		#return
	# 这样也行
	if not is_inside_tree():
		return
	
	num_of_relics = relics.get_child_count()
	max_page = ceili(num_of_relics / float(RELICS_PER_PAGE))
	
	left_button.disabled = current_page <= 1
	right_button.disabled = current_page >= max_page


func _tween_to(x_position: float) -> void:
	if tween:
		tween.kill()
	
	print(x_position)
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(relics, "position:x", x_position, TWEEN_SCROLL_DURATION)


func _on_left_button_pressed() -> void:
	if current_page > 1:
		current_page -= 1
		update()
		relics_position += page_width
		_tween_to(relics_position)


func _on_right_button_pressed() -> void:
	if current_page < max_page:
		current_page += 1
		update()
		relics_position -= page_width
		_tween_to(relics_position)


func _on_relics_child_order_changed() -> void:
	update()
