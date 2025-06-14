extends Control

const ThemeData = preload("res://scripts/Theme.gd")

@onready var play_button = $MarginContainer/VBoxContainer/play_button
@onready var settings_button = $MarginContainer/VBoxContainer/HBoxContainer/settings_button
@onready var logo_texture_rect = $MarginContainer/VBoxContainer/MarginContainer/TextureRect
@onready var mascot_texture_rect = $SpectacledGiraffeMascot

func _ready():
				_add_background()
				play_button.pressed.connect(_on_play_pressed)
				settings_button.pressed.connect(_on_settings_pressed)
				for btn in [play_button, settings_button]:
                                                             btn.add_theme_color_override("font_color", ThemeData.LETTER_COLOR)
                                                             ThemeData.apply_line_color(ThemeData.GRAPHIC_COLOR)

func _add_background():
				var bg = ColorRect.new()
				bg.anchor_right = 1
				bg.anchor_bottom = 1
                             bg.color = ThemeData.BG_COLOR
				add_child(bg)
				move_child(bg, 0)


func _on_play_pressed():
				var puzzle_scene = preload("res://scenes/PuzzleScreen.tscn").instantiate()
				get_tree().root.add_child(puzzle_scene)
				queue_free()     # Remove MainMenu

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
