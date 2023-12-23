class_name CaptureMouse
extends Control
## Control node that captures the mouse for games that require it. 
##
## Used for games that use the mouse to move the camera (ex. FPS or third-person shooters).

func _gui_input(event):
	if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
