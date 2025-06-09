extends Control

@onready var tab_container = $TabContainer

# Enum for tab indices (optional but helpful for readability)
enum Tabs {
	MAIN_MENU = 0,
	PUZZLE = 1,
	HISTORY = 2,
	SETTINGS = 3
}

func _ready():
	# Start at the main menu
	tab_container.current_tab = Tabs.MAIN_MENU

func go_to_main_menu():
	tab_container.current_tab = Tabs.MAIN_MENU

func go_to_puzzle():
	tab_container.current_tab = Tabs.PUZZLE

func go_to_history():
	tab_container.current_tab = Tabs.HISTORY

func go_to_settings():
	tab_container.current_tab = Tabs.SETTINGS
