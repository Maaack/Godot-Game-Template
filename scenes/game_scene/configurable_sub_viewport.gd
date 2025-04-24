extends SubViewport

@export var anti_aliasing_key : StringName = "Anti-aliasing"
@export var video_section : StringName = AppSettings.VIDEO_SECTION

func _ready() -> void:
	var anti_aliasing : int = Config.get_config(video_section, anti_aliasing_key, Viewport.MSAA_DISABLED)
	msaa_2d = anti_aliasing as MSAA
	msaa_3d = anti_aliasing as MSAA
