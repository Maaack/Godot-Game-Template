# Joypad Inputs

This page covers topics related to working with joypads.

## Recognized Devices

- Xbox
- Playstation 4
- Playstation 5

### Unconfirmed

- Switch
- Steam Deck

## Added UI Inputs

There is a `override.cfg` in the project root directory that adds a few additional inputs to the project's built-in UI actions.  

These additional inputs are for joypads and include the following:  

- `UI Accept`: A Button (Xbox A / Sony X)  
- `UI Cancel`: Back Button (Xbox Back / Sony Select)  
- `UI Page Up`: Left Shoulder (Xbox LB / Sony L1)  
- `UI Page Down`: Right Shoulder (Xbox RB / Sony R2)  

However, for these to work in exported versions of the project, the inputs need to either be added manually to the project's built-in actions, or `override.cfg` will need to be included in the exports. The latter can be done by including the pattern (`*.cfg`) in **Filters to export non-resource files/folders** under the *Resources* tab of the *Export* window.

## Web Builds

Godot (or the template) currently does not support joypad device detection on the web. If icons are being used for input remapping, the joypad icons will *not* update automatically to match a new detected controller.