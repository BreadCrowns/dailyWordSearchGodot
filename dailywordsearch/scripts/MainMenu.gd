extends Control

@onready var play_button = $ContentContainer/VBox/PlayButton
@onready var history_button = $HistoryButton
@onready var settings_button = $SettingsButton
@onready var title_label = $ContentContainer/VBox/Title
@onready var background = $Background

func _ready():
        play_button.pressed.connect(_on_play_pressed)
        history_button.pressed.connect(_on_history_pressed)
        settings_button.pressed.connect(_on_settings_pressed)
        title_label.text = "Spectacled Giraffe Daily"
        play_button.text = "Word Search Today"
        background.texture = load("res://images/giraffe_background.svg")
        var hist_tex = load("res://images/history_icon.svg")
        history_button.texture_normal = hist_tex
        history_button.texture_pressed = hist_tex
        history_button.texture_hover = hist_tex
        var set_tex = load("res://images/settings_icon.svg")
        settings_button.texture_normal = set_tex
        settings_button.texture_pressed = set_tex
        settings_button.texture_hover = set_tex

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
