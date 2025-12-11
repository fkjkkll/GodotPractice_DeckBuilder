class_name StatusEffect extends Effect

var status: Status

func execute(_targets: Array[Node]) -> void:
	for target in _targets:
		if not target: continue
		if target is Enemy or target is Player:
			var status_handler = target.status_handler as StatusHandler
			status_handler.add_status(status)
			if sound:
				SFXPlayer.play(sound)
