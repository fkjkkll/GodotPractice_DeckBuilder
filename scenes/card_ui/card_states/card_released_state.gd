extends CardState


func enter() -> void:
	if not card_ui.targets.is_empty():
		Events.tooltip_hide_requested.emit()
		card_ui.play()
		
	# 因为切换状态时，需要退出旧状态，再进入新状态，你都没进入，如何退出呢
	# 退出状态的前提是已经进入了该状态，所以不能在此处判断played然后emit


func Post_enter() -> void:
	transition_requested.emit(self, CardState.State.BASE)
