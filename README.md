# Haptics Maze Game

A mobile accessibility game built with **Godot Engine** that helps visually impaired players navigate a maze using **haptic feedback**. The player controls a bat that moves step by step through a procedurally generated maze. Vibrations guide the player when they hit walls, and reaching a target tile advances to a new maze.

## Features

* **Procedural Maze Generation**: Each level generates a new maze with random walls.
* **Step-by-Step Movement**: Swipe controls move the bat one cell at a time.
* **Haptic Feedback**:

  * Heavy vibration when the bat hits a wall.
  * Medium vibration when reaching the target tile.
* **Target Tile**: Placed at the furthest empty point from the bat. Stepping on it triggers vibrations and reloads the maze.
* **Accessibility-Focused**: Designed specifically for blind or visually impaired players.

## Installation

1. Install [Godot Engine](https://godotengine.org/) (version 4.x recommended).
2. Clone this repository:

```bash
git clone https://github.com/KDesp73/haptics-maze.git
cd haptics-maze
```

3. Open the project in Godot.
4. Configure your mobile export template (Android/iOS) if you want to run on a device.

## Controls

* **Swipe**: Move the bat in the swipe direction (up, down, left, right).

## How It Works

1. The maze is generated procedurally based on screen size and configuration parameters.
2. The bat is placed in a safe, empty cell with an open neighbor.
3. The target tile is placed at the **furthest empty cell from the bat**, ensuring a challenging path.
4. The player swipes to move the bat one cell at a time.
5. Haptic feedback guides the player:

   * Collision with walls → heavy vibration.
   * Reaching the target → medium vibration and maze reload.

## Notes

* Make sure haptics permissions are enabled on the device.
* The project currently targets Android; iOS support may require additional setup.

## License

[MIT License](./LICENSE) – feel free to modify and redistribute.
