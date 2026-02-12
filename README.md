# Agebound Survival - Android Vertical Slice

This is a Godot 4.3 project designed for mobile-first development. It includes a voxel engine, survival mechanics, and the Primal Age progression system.

## Setup Instructions (Android)

1.  **Install Godot for Android:**
    -   Download "Godot Editor 4" from the Google Play Store or F-Droid.
    -   Ensure it is version 4.x (preferably 4.3 or later).

2.  **Import the Project:**
    -   Download this repository to your device.
    -   Open Godot on Android.
    -   Tap "Import Project".
    -   Navigate to the folder containing `project.godot` and select it.
    -   Tap "Edit".

3.  **Run the Game:**
    -   Once the editor loads, tap the "Play" button (triangle icon) at the top right.
    -   The game should launch directly on your device.

## Controls

-   **Left Joystick (Visual):** Move character.
-   **Right Joystick (Visual):** Rotate camera / Look around.
-   **Interact:**
    -   **Tap Right Side:** Place Block.
    -   **Hold Right Side:** Break Block (with progress bar).
-   **Crafting:** Use the buttons on the bottom right to craft items.

## Features

-   **Infinite Voxel World:** Procedurally generated terrain.
-   **Survival Stats:** Hunger, Thirst, Health.
-   **Age System:** Currently in "Primal Age". Complete quests to advance.
-   **Crafting:** Craft Stone Axe, Campfire, etc.
-   **Mobs:** Basic hostile mobs (Red Cubes) roam the world.

## Developer Notes

-   **Scripts:** Located in `res://scripts/`.
-   **Scenes:** Located in `res://scenes/`.
-   **Main Scene:** `res://scenes/Main.tscn` (automatically loaded).

If you encounter issues with `.tscn` files, you can regenerate them by opening `Main.gd` or `UI.tscn` in the editor and saving. The logic is primarily script-based for robustness.
