# Game Saving

> [!IMPORTANT]  
> This system doesn't follow the same conventions as the others.  
> It is subject to change.  

> [!WARNING]  
> Discourage players from sharing save files. Do not use this for cloud saving, either.  
> Resource files are vulnerable to having scripts injected in them.  
> A safer save system is planned.  


The templates and plugin suite aim to keep most class definitions within the addon. These are not usually expected change. Unlike the other classes, the `GameState` and `LevelState` are defined for the developer to edit to their needs.

## Usage

The `GlobalState` static class keeps the state saved to a resource. The developer is responsible for making sure `GlobalState.save()` gets called when they want the state saved to the disk.  

### Game State

The `GameState` class represents the state of a single playthrough of the game. It currently stores the current level, the max level reached, and the state of each level currently visited.

It is currently expected to be used as a singleton, too.


### Level State

The `LevelState` class represents the state of a single level in a playthrough of the game. It currently stores whether the tutorial has been read, and a color, if the player has set one in the example levels.  It can be used to store the states of many other level specific features.