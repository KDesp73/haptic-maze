extends CanvasLayer

@onready var panel = $Panel
@onready var checkbox = $Panel/CenterContainer/HBoxContainer/CheckButton

signal glitch_mode_changed(enabled: bool)

func _ready() -> void:
	_styling()

	# Ignore input for double-tap
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel/CenterContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel/CenterContainer/HBoxContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Connect checkbox toggled signal
	checkbox.connect("toggled", Callable(self, "_on_checkbox_toggled"))


func _styling() -> void:
	# Make panel fill the entire screen
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 0.0
	panel.offset_top = 0.0
	panel.offset_right = 0.0
	panel.offset_bottom = 0.0
	panel.modulate = Color(0, 0, 0, 0.6)

	# Ensure CenterContainer fills panel
	var center_container = panel.get_node("CenterContainer")
	center_container.anchor_left = 0.0
	center_container.anchor_top = 0.0
	center_container.anchor_right = 1.0
	center_container.anchor_bottom = 1.0
	center_container.offset_left = 0.0
	center_container.offset_top = 0.0
	center_container.offset_right = 0.0
	center_container.offset_bottom = 0.0

	# Enlarge checkbox font
	checkbox.add_theme_font_size_override("font_size", 50)
	checkbox.add_theme_color_override("font_color", Color(1, 1, 1, 1))

	# Increase spacing between checkbox and label
	var hbox = panel.get_node("CenterContainer/HBoxContainer")
	hbox.add_theme_constant_override("separation", 32)


func _on_checkbox_toggled(pressed: bool) -> void:
	emit_signal("glitch_mode_changed", pressed)


func set_checkbox_state(state: bool) -> void:
	checkbox.set_pressed(state)
