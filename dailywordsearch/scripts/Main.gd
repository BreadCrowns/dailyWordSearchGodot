extends Control

# Paths to scenes for navigation
const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const PUZZLE_SCENE := "res://scenes/PuzzleScreen.tscn"

func _ready():
	# Load the main menu when the scene starts
	go_to_main_menu()

# Switch to the main menu scene
func go_to_main_menu():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

# Switch to the puzzle scene
func go_to_puzzle():
	get_tree().change_scene_to_file(PUZZLE_SCENE)

# Placeholder for a history screen
func go_to_history():
	print("History screen not implemented")
# Placeholder for a settings screen
func go_to_settings():
	print("Settings screen not implemented")
