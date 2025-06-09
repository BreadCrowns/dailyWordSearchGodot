extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var history_button = $VBoxContainer/HistoryButton
@onready var settings_button = $VBoxContainer/SettingsButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	history_button.pressed.connect(_on_history_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_play_pressed():
		var puzzle_scene = preload("res://scenes/PuzzleScreen.tscn").instantiate()
		get_tree().root.add_child(puzzle_scene)
		queue_free()	 # Remove MainMenu

func _on_history_pressed():
		var scene = load("res://scenes/HistoryScreen.tscn")
		if scene:
			var hist = scene.instantiate()
			get_tree().root.add_child(hist)
			queue_free()
		else:
			push_error("Failed to load HistoryScreen.tscn")

func _on_settings_pressed():
		var scene = load("res://scenes/SettingsScreen.tscn")
		if scene:
			var settings = scene.instantiate()
			get_tree().root.add_child(settings)
			queue_free()
		else:
			push_error("Failed to load SettingsScreen.tscn")
