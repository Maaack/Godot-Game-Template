# Input Icon Mapping

The `InputIconMapper` in `input_options_menu.tscn` is a generalized tool meant to be broadly compatible with freely licensed icon asset packs. Instructions on how to use it with a few of these packs are provided, with links to download them from their creator's page.

## Kenney Input Prompts

Available from [kenney.nl](https://kenney.nl/assets/input-prompts) and [itch.io](https://kenney-assets.itch.io/input-prompts).

This pack is organized by `Device/IconType`. The `IconTypes` for each device are just `Default`, `Vector`, or `Double`. These instructions will assume using `Default`. In the inspector of `InputIconMapper`, set the `directories` to include the subdirectories of the asset pack.  
* `.../kenney_input-prompts/Keyboard & Mouse/Default`  
* `.../kenney_input-prompts/Generic/Default`  
* `.../kenney_input-prompts/Xbox Series/Default`  
* `.../kenney_input-prompts/PlayStation Series/Default`  
* `.../kenney_input-prompts/Nintendo Switch/Default`  
* `.../kenney_input-prompts/Steam Deck/Default`  

Set `replace_strings` with the key pairs:  
* `"Generic Stick": "Generic Left Stick"`  
* `"Guide": "Home"`  
* `"Stick L": "Left Stick"`  
* `"Stick R": "Right Stick"`  
* `"Trigger L 1": "Left Shoulder"`  
* `"Trigger L 2": "Left Trigger"`  
* `"Trigger R 1": "Right Shoulder"`  
* `"Trigger R 2": "Right Trigger"`  

### Filled Icons

Under the `FileLister` properties of the `InputIconMapper`, expand the `Constraints` and `Advanced Search` tabs. Set `ends_with=".png"` and `not_ends_with="outline.png"`.

Press `Refresh Files`.

Set `filtered_strings` to:
* `keyboard`
* `color`
* `button`

If you want to use colored icons, in `prioritized_strings` add `color`. Otherwise set `filter="color"`.  

Press `Match Icons to Inputs`.  

Validate the results by inspecting the `matching_icons` dictionary.

### Outlined Icons

Not all icons have outlined versions, so we will end up including the filled icons as fallback, and prioritizing outlined.

Under the `FileLister` properties of  the `InputIconMapper`, expand the `Constraints` and `Advanced Search` export groups. Set `ends_with=".png"`. 

Press `Refresh Files`. 

Set `filtered_strings` to:
* `keyboard`
* `color`
* `outline`

In `prioritized_strings` add `outline`. If you want to use colored icons, in `prioritized_strings` add `color`, too. Otherwise set `filter="color"`.  

Press `Match Icons to Inputs`.  

Validate the results by inspecting the `matching_icons` dictionary.

## Kenny Input Prompts Pixel 16x

Incompatible: File names not useable.

## Xelu 's Free Controller & Key Prompts
Available from [thoseawesomeguys.com](https://thoseawesomeguys.com/prompts/).

This pack is organized by `Device`. In the inspector of `InputIconMapper`, set the `directories` to include the subdirectories of the asset pack. Assumes using the `Dark` icon set with the keyboard and mouse.
* `.../Xelu_Free_Controller&Key_Prompts/Keyboard & Mouse/Dark` 
* `.../Xelu_Free_Controller&Key_Prompts/Xbox Series`  
* `.../Xelu_Free_Controller&Key_Prompts/PS5`  
* `.../Xelu_Free_Controller&Key_Prompts/Switch`  
* `.../Xelu_Free_Controller&Key_Prompts/Steam Deck`  

Under the `FileLister` properties of the `InputIconMapper`, expand the `Constraints` and `Advanced Search` tabs. Set `ends_with=".png"`.

Press `Refresh Files`. 

Set `filtered_strings` to:
* `dark`
* `key`.

Set `replace_strings` with the key pairs:  
* `"Ps 5": "Playstation"`  
* `"Xbox Series X": "Xbox"`  
* `"Steam Deck": "Steamdeck"`
* `"L 1": "Left Shoulder"`
* `"R 1": "Right Shoulder"`
* `"L 2": "Left Trigger"`
* `"R 2": "Right Trigger"`
* `"Click": "Press"`

Set `add_stick_directions=true`.

Press `Match Icons to Inputs`.

Validate the results by inspecting the `matching_icons` dictionary.