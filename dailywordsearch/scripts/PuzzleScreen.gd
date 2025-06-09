extends Control

# Node references for the grid, word labels, and dynamic line container
@onready var grid = $MarginContainer/VBoxContainer/MarginContainer/AspectRatioContainer/GridContainer
@onready var line_layer = $MarginContainer/VBoxContainer/MarginContainer/AspectRatioContainer/LineLayer
@onready var back_button = $MarginContainer/VBoxContainer/HBoxContainer/back_button
@onready var title_label = $MarginContainer/VBoxContainer/title
@onready var word_list_col1 = [
	$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_0,
	$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_1,
	$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_2,
	$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_3,
	$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_4,
]
@onready var word_list_col2 = [
	$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_0,
	$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_1,
	$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_2,
	$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_3,
	$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_4,
]
@onready var word_label_center = $MarginContainer/VBoxContainer/word_list_container/center_word_container/word_label_center

# Grid configuration
const GRID_SIZE = 12
var grid_letters: String = "NERSIEEBLNMEAPCESNPIBPMAEMDMTUFRBAAHMTAORDREMMZHOORSSESECROTAGUTHLREGTEZNEURIBOROIEMFBMEBMOFLOMDLBRGLABITENNEEENNHESPROCSFZUISCOSRHEHELHAFLMRAEA"

# Word list
var words: Array = ["Corpse", "Shamble", "Bite", "Infected", "Rot", "Moan", "Groan", "Pursue", "Flesh", "Hunger", "Zombie"]

# Puzzle date and history tracking
var puzzle_date: String
var solved_words: Array = []
var http_request: HTTPRequest

# Dragging state variables
var drag_start: Vector2i = Vector2i(-1, -1)
var drag_end: Vector2i = Vector2i(-1, -1)
var dragging: bool = false
var active_line: Line2D = null

# Font and palette handling
var fonts: Array = []
var title_font_index: int = 0
var grid_font_index: int = 0
var word_font_index: int = 0

var palettes: Array = []
var palette_index: int = 0
var bg_rect: ColorRect

func _init_background():
        bg_rect = ColorRect.new()
        bg_rect.anchor_right = 1
        bg_rect.anchor_bottom = 1
        bg_rect.color = Color.BLACK
        add_child(bg_rect)
        bg_rect.lower()

func _init_fonts():
        var dir = DirAccess.open("res://fonts")
        if dir:
                dir.list_dir_begin()
                var file = dir.get_next()
                while file != "":
                        if not dir.current_is_dir() and file.get_extension().to_lower() in ["ttf", "otf", "fnt"]:
                                fonts.append("res://fonts/" + file)
                        file = dir.get_next()
                dir.list_dir_end()
        fonts.sort()

func _init_palettes():
        palettes = [
                {"name": "Vibrant", "bg": Color(0.2,0.2,0.6), "letter": Color.WHITE, "line": Color(1,0.4,0.4)},
                {"name": "Sunset", "bg": Color(1,0.8,0.6), "letter": Color(0.2,0.1,0.1), "line": Color(0.9,0.3,0.2)},
                {"name": "Forest", "bg": Color(0.1,0.2,0.1), "letter": Color(0.8,1,0.8), "line": Color(0.3,0.6,0.3)},
                {"name": "Ocean", "bg": Color(0.1,0.3,0.5), "letter": Color(0.9,0.9,1), "line": Color(0.2,0.7,0.9)},
                {"name": "Monochrome", "bg": Color(0.15,0.15,0.15), "letter": Color(0.9,0.9,0.9), "line": Color(0.6,0.6,0.6)},
                {"name": "Pastel", "bg": Color(0.9,0.9,1), "letter": Color(0.3,0.3,0.4), "line": Color(0.6,0.5,0.9)},
                {"name": "Cyberpunk", "bg": Color(0.1,0.0,0.2), "letter": Color(1,0.2,0.8), "line": Color(0.2,1,0.8)},
                {"name": "Earthy", "bg": Color(0.4,0.3,0.2), "letter": Color(0.95,0.9,0.8), "line": Color(0.6,0.5,0.4)},
                {"name": "Vintage", "bg": Color(0.6,0.5,0.4), "letter": Color(0.1,0.1,0.1), "line": Color(0.4,0.3,0.2)},
                {"name": "Midnight", "bg": Color(0.05,0.05,0.1), "letter": Color(0.8,0.8,1), "line": Color(0.4,0.4,0.8)}
        ]

func _apply_palette():
        if palettes.is_empty():
                return
        var p = palettes[palette_index]
        bg_rect.color = p["bg"]
        title_label.add_theme_color_override("font_color", p["letter"])
        for child in grid.get_children():
                if child is Label:
                        child.add_theme_color_override("font_color", p["letter"])
        for label in word_list_col1 + word_list_col2 + [word_label_center]:
                if label.get_theme_color("font_color") != Color.GREEN:
                        label.add_theme_color_override("font_color", p["letter"])
        for line in line_layer.get_children():
                if line is Line2D:
                        line.default_color = p["line"]
                        line.modulate = p["line"]
        print("Palette: %s" % p.get("name", str(palette_index)))

func _apply_title_font():
        if fonts.is_empty():
                return
        var path = fonts[title_font_index]
        title_label.add_theme_font_override("font", load(path))
        print("Title font: %s" % path)

func _apply_grid_font():
        if fonts.is_empty():
                return
        var path = fonts[grid_font_index]
        for child in grid.get_children():
                if child is Label:
                        child.add_theme_font_override("font", load(path))
        print("Grid font: %s" % path)

func _apply_word_font():
        if fonts.is_empty():
                return
        var path = fonts[word_font_index]
        for label in word_list_col1 + word_list_col2 + [word_label_center]:
                label.add_theme_font_override("font", load(path))
        print("Word bank font: %s" % path)

func _cycle_title_font():
        if fonts.is_empty():
                return
        title_font_index = (title_font_index + 1) % fonts.size()
        _apply_title_font()
        _print_status()

func _cycle_grid_font():
        if fonts.is_empty():
                return
        grid_font_index = (grid_font_index + 1) % fonts.size()
        _apply_grid_font()
        _print_status()

func _cycle_word_font():
        if fonts.is_empty():
                return
        word_font_index = (word_font_index + 1) % fonts.size()
        _apply_word_font()
        _print_status()

func _cycle_palette():
        if palettes.is_empty():
                return
        palette_index = (palette_index + 1) % palettes.size()
        _apply_palette()
        _print_status()

func _print_status():
        var t_font = fonts[title_font_index] if not fonts.is_empty() else ""
        var g_font = fonts[grid_font_index] if not fonts.is_empty() else ""
        var w_font = fonts[word_font_index] if not fonts.is_empty() else ""
        var p_name = palettes[palette_index].get("name", str(palette_index)) if not palettes.is_empty() else ""
        print("Title font: %s | Grid font: %s | Word font: %s | Palette: %s" % [t_font, g_font, w_font, p_name])


# Initialization
func _ready():
        http_request = HTTPRequest.new()
        add_child(http_request)
        http_request.request_completed.connect(_on_puzzle_request_completed)
        puzzle_date = Time.get_date_string_from_system()

        _init_background()
        _init_fonts()
        _init_palettes()
        _apply_title_font()
        _apply_palette()
        _print_status()

        request_puzzle(puzzle_date)
        set_process_input(true)
        back_button.pressed.connect(_on_back_pressed)

# Handle back button press
func _on_back_pressed():
	var scene = load("res://scenes/MainMenu.tscn")
	if scene:
		var main_menu = scene.instantiate()
		get_tree().root.add_child(main_menu)
		queue_free()
	else:
		push_error("Failed to load MainMenu.tscn")

func request_puzzle(date: String):
	var url = "https://your-project.firebaseio.com/puzzles/%s.json" % date
	http_request.request(url)

func _on_puzzle_request_completed(result, response_code, headers, body):
        if result == OK and response_code == 200:
                var text = body.get_string_from_utf8()
                var data = JSON.parse_string(text)
                if typeof(data) == TYPE_DICTIONARY:
                        grid_letters = data.get("grid", grid_letters)
                        words = data.get("words", words)
        generate_grid()
        load_words()
        _print_status()

# Generate the letter grid from the predefined string
func generate_grid():
	if grid_letters.length() < GRID_SIZE * GRID_SIZE:
		push_error("GRID_LETTERS string is too short for grid size")
		return

	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()

        var index := 0
        for y in range(GRID_SIZE):
                for x in range(GRID_SIZE):
                        var label = Label.new()
                        label.text = grid_letters[index]
                        index += 1
                        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
                        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                        label.size_flags_vertical = Control.SIZE_EXPAND_FILL
                        label.custom_minimum_size = Vector2(48, 48)
                        label.add_theme_font_size_override("font_size", 24)
                        if not fonts.is_empty():
                                label.add_theme_font_override("font", load(fonts[grid_font_index]))
                        label.add_theme_color_override("font_color", palettes[palette_index]["letter"] if not palettes.is_empty() else Color.WHITE)
                        label.set_meta("grid_pos", Vector2i(x, y))
                        grid.add_child(label)

# Load and display the word list
func load_words():
        for i in range(min(5, words.size())):
                word_list_col1[i].text = words[i].to_upper()
                word_list_col1[i].add_theme_color_override("font_color", palettes[palette_index]["letter"] if not palettes.is_empty() else Color.WHITE)
                word_list_col1[i].add_theme_font_size_override("font_size", 30)
                if not fonts.is_empty():
                        word_list_col1[i].add_theme_font_override("font", load(fonts[word_font_index]))
        for i in range(5, min(10, words.size())):
                word_list_col2[i - 5].text = words[i].to_upper()
                word_list_col2[i - 5].add_theme_color_override("font_color", palettes[palette_index]["letter"] if not palettes.is_empty() else Color.WHITE)
                word_list_col2[i - 5].add_theme_font_size_override("font_size", 30)
                if not fonts.is_empty():
                        word_list_col2[i - 5].add_theme_font_override("font", load(fonts[word_font_index]))
        if words.size() > 10:
                word_label_center.text = "?????"
        else:
                word_label_center.text = ""
        word_label_center.add_theme_color_override("font_color", palettes[palette_index]["letter"] if not palettes.is_empty() else Color.WHITE)
        word_label_center.add_theme_font_size_override("font_size", 30)
        if not fonts.is_empty():
                word_label_center.add_theme_font_override("font", load(fonts[word_font_index]))

# Input handling
func _input(event):
        if event is InputEventKey and event.pressed and not event.echo:
                match event.keycode:
                        KEY_T:
                                _cycle_title_font()
                        KEY_G:
                                _cycle_grid_font()
                        KEY_W:
                                _cycle_word_font()
                        KEY_P:
                                _cycle_palette()
                return
        if event is InputEventScreenTouch or event is InputEventMouseButton:
                if event.pressed:
                        if not is_point_inside_grid(event.position):
                                dragging = false
                                return
			drag_start = get_grid_cell_from_position(event.position)
			dragging = true
			active_line = Line2D.new()
			active_line.width = 30
                        active_line.default_color = palettes[palette_index]["line"] if not palettes.is_empty() else Color.WHITE
                        active_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
                        active_line.end_cap_mode = Line2D.LINE_CAP_ROUND
                        line_layer.add_child(active_line)
			var start_pos = get_grid_cell_center(drag_start) - line_layer.get_global_position()
			active_line.add_point(start_pos)
			active_line.add_point(start_pos)
		else:
			if not dragging or active_line == null:
				return
			dragging = false
			drag_end = get_grid_cell_from_position(event.position)
			var result = false
			if is_straight_line(drag_start, drag_end):
				result = process_selection(drag_start, drag_end)
			if result:
				var end_pos = get_grid_cell_center(drag_end) - line_layer.get_global_position()
				active_line.set_point_position(1, end_pos)
			else:
				line_layer.remove_child(active_line)
				active_line.queue_free()
			active_line = null
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and dragging and active_line != null:
		var current_pos = event.position - line_layer.get_global_position()
		active_line.set_point_position(1, current_pos)

# Word selection logic
func process_selection(start: Vector2i, end: Vector2i) -> bool:
	var direction = end - start
	var step = direction.sign()
	if not is_straight_line(start, end):
		return false

	var selected_word := ""
	var pos = start
	while pos != end + step:
		var index = pos.y * GRID_SIZE + pos.x
		if index >= 0 and index < grid_letters.length():
			selected_word += grid_letters[index]
		pos += step

	var match := words.any(func(w): return w.to_lower() == selected_word.to_lower() or w.to_lower() == selected_word.reverse().to_lower())
	if match:
		var normalized = selected_word.to_lower()
		if normalized not in solved_words:
			solved_words.append(normalized)
		for label in word_list_col1 + word_list_col2 + [word_label_center]:
			if words.size() > 10 and label == word_label_center and (words[10].to_lower() == normalized or words[10].to_lower() == normalized.reverse()):
				label.text = words[10].to_upper()
				label.add_theme_color_override("font_color", Color.GREEN)
				break
			elif label.text.to_lower() == normalized or label.text.to_lower() == normalized.reverse():
				label.add_theme_color_override("font_color", Color.GREEN)
				break
		if solved_words.size() == words.size():
			_record_history()
		return true
	return false

func _record_history():
	var path = "user://history.json"
	var history = []
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_ARRAY:
			history = data
	history.append({"date": puzzle_date, "solved_words": solved_words})
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(history))
	file.close()

# Utilities
func get_grid_cell_from_position(pos: Vector2) -> Vector2i:
	var grid_pos = grid.get_global_position()
	var grid_size = grid.get_size()
	var cell_size = grid_size / float(GRID_SIZE)
	var local_pos = pos - grid_pos
	var x = clamp(floor(local_pos.x / cell_size.x), 0, GRID_SIZE - 1)
	var y = clamp(floor(local_pos.y / cell_size.y), 0, GRID_SIZE - 1)
	return Vector2i(x, y)

func get_grid_cell_center(pos: Vector2i) -> Vector2:
	var grid_pos = grid.get_global_position()
	var cell_size = grid.get_size() / Vector2(GRID_SIZE, GRID_SIZE)
	return grid_pos + (Vector2(pos) * cell_size) + (cell_size / 2)

func is_point_inside_grid(pos: Vector2) -> bool:
	var grid_rect = Rect2(grid.get_global_position(), grid.get_size())
	return grid_rect.has_point(pos)

func is_straight_line(start: Vector2i, end: Vector2i) -> bool:
	var direction = end - start
	return abs(direction.x) == abs(direction.y) or direction.x == 0 or direction.y == 0
