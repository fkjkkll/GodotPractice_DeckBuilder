extends CardState


func enter() -> void:
	card_ui.drop_point_detector.monitoring = true
	card_ui.original_index = card_ui.get_index() # 记录放回时应该插入的位置

func on_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		transition_requested.emit(self, CardState.State.DRAGGING)
