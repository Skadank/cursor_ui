# Cursor UI System for UEFN

This project implements a modular cursor-based UI system in [Verse](https://dev.epicgames.com/documentation/en-us/uefn/verse/) for Unreal Editor for Fortnite (UEFN). It provides interactive menus and demos, including crafting, merging, target shooting, world editing, and AI control, all using custom cursor logic.

## Features

- **Cursor-Based Menus:** Abstract [`cursor_menu`](Source/Classes/cursor_menu.verse) class for building interactive UI menus.
- **Crafting Demo:** Drag-and-drop crafting system ([`crafting_menu`](Source/Classes/Demos/crafting_demo.verse)).
- **Merge Game Demo:** Merge elements to create new items ([`merge_menu`](Source/Classes/Demos/merge_game_demo.verse)).
- **Target Shooter Demo:** Click targets to score points ([`target_game_menu`](Source/Classes/Demos/target_game_demo.verse)).
- **World Editor Demo:** Move and edit world objects ([`world_editor_menu`](Source/Classes/Demos/world_editor_demo.verse)).
- **World Bomber Demo:** Place and detonate explosives ([`world_bomber_menu`](Source/Classes/Demos/world_bomber_demo.verse)).
- **World Merge Game Demo:** Merge world objects with prop spawning ([`world_merge_menu`](Source/Classes/Demos/world_merge_game_demo.verse)).
- **World AI Controller Demo:** Control NPC movement and attacks ([`world_ai_controller_menu`](Source/Classes/Demos/world_ai_controller_demo.verse)).
- **Device Managers:** Modular device managers for menus and NPCs ([`menu_manager_device`](Source/Devices/menu_manager_device.verse), [`npc_manager_device`](Source/Devices/npc_manager_device.verse)).
- **Utility Functions:** Common UI and math utilities ([`utilities.verse`](Source/utilities.verse)).

## UEFN Project Structure

Note: This Git repository does not reflect the UEFN project structure required for this system and is instead a substitute for my shortcomings in UEFN project organization.

<pre>
📁 Root
├── 📁 Materials
├── 📁 Textures
└── 📁 Verse
</pre>

## Usage

1. **Import into UEFN:** Add the project files to your UEFN project.
2. **Configure Devices:** Set up device properties in UEFN for input triggers, audio, props, etc.
3. **Run Demos:** Use the demo buttons to launch different cursor-based UI demos.

## Customization

- Add new UI elements by extending [`ui_element`](Source/Classes/ui_elements.verse).
- Create new menus by subclassing [`cursor_menu`](Source/Classes/cursor_menu.verse).

## Credits

- Huge thanks to [@JaireWho](https://x.com/JaireWho) for his feedback, player direction to cursor position code, and spatial math knowledge.

## Known Limitations

- HUD Scaling settings other than 100% cause some problems, mainly issues within the world space applications as the cursor will be offset relative to the scaling applied and not be hovering the world areas you would expect. Thanks [@Sprintermax](https://x.com/Sprintermax) for catching this one.
