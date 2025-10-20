@tool
class_name Vector2ListOptionControl
extends ListOptionControl

func _value_title_map(value : Variant) -> String:
	if value is Vector2 or value is Vector2i:
		return "%d x %d" % [value.x , value.y]
	else:
		return super._value_title_map(value)
