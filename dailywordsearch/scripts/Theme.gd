extends Node

class_name ThemeConfig

# Font paths
const TITLE_FONT_PATH := "res://fonts/Roboto-Light.ttf"
const GRID_FONT_PATH := "res://fonts/Roboto-Bold.ttf"
const WORD_FONT_PATH := "res://fonts/Roboto-Light.ttf"

# Color palette
const BG_COLOR := Color(239.0 / 255.0, 251.0 / 255.0, 249.0 / 255.0)
const LETTER_COLOR := Color(38.0 / 255.0, 70.0 / 255.0, 83.0 / 255.0)
const GRAPHIC_COLOR := Color(90.0 / 255.0, 32.0 / 255.0, 46.0 / 255.0)
const LINE_COLOR := Color(243.0 / 255.0, 155.0 / 255.0, 83.0 / 255.0)
const SECRET_COLOR := Color(231.0 / 255.0, 111.0 / 255.0, 81.0 / 255.0)

# Shared ShaderMaterial used for all tinted graphics.
const LINE_MATERIAL := preload("res://assets/SharedLineMaterial.tres")

static func apply_line_color(color: Color) -> void:
	LINE_MATERIAL.set_shader_parameter("line_color", color)
