# meta-name: Effect
# meta-description: Create an effect which can be applied to a target.
class_name MyAwesomeEffect
extends Effect

var member_var := 0

func execute(_targets: Array[Node]) -> void:
	print("My effect targets them: %s" % targets)
	print("It dose %s something" % member_var)
