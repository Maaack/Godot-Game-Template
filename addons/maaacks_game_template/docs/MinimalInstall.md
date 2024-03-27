# Miminal Installation

These instructions are for slightly more experienced Godot developers, that want to use a minimal version of the template (ie. contents of `base/` exclusively). It is not recommended for beginner users of the template, or Godot. However, for those that would like the template's bare bones, content has been organized to make it easier to cut large chunks out.

1.  Update `Project Settings`.
    1.  Go to `Project > Project Settings… > General > Application > Run`.
    2.  Update `Main Scene` to `res://addons/maaacks_game_template/base/scenes/InitApp/InitApp.tscn`.
    3.  Go to `Project > Project Settings… > Autoload`.
    4.  Remove autoloads that start with the path `res://addons/maaacks_game_template/extras/*`.
        1.  `ProjectUiSoundController`
        2.  `ProjectLevelLoader`
        3.  `RuntimeLogger`
    5.  Close the window.
2.  Delete the extra folders from the plugin:
    1.  `res://addons/maaacks_game_template/extras/`
    2.  `res://addons/maaacks_game_template/examples/`
3.  If using the template version, delete the extra folders from the project's root directory:
    1.  `res://Media/`
    2.  `res://Examples/`
    3.  `res://ATTRIBUTION.md`
    4.  `res://ATTRIBUTION_example.md`
    5.  `res://LICENSE.txt`
    6.  `res://README.md`
4.  Reload the project.
