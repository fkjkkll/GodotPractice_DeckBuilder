class_name Status extends Resource

signal status_applied(status: Status)
signal status_changed

enum Type { START_OF_TURN, END_OF_TURN, EVENT_BASED }
enum StackType { NONE, INTENSITY, DURATION }

@export_group("Status Data")
@export var id: String
@export var type: Type
@export var stack_type: StackType
@export var can_expire: bool
@export var duration: int: set = _set_duration
@export var stacks: int: set = _set_stacks

@export_group("Status Visual")
@export var icon: Texture
@export_multiline var tooltip: String


func _set_duration(value: int) -> void:
	duration = value
	status_changed.emit()


func _set_stacks(value: int) -> void:
	stacks = value
	status_changed.emit()


func initialize_status(_target: Node) -> void:
	pass


func apply_status(_target: Node) -> void:
	status_applied.emit(self)


func get_tooltip() -> String:
	return tooltip
