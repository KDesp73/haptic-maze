extends Node
class_name HapticsWrapper

@onready var _plugin = preload("res://addons/GodotAndroidHaptics/haptics_wrapper.gd").new()

# --- PUBLIC METHODS ---
func effect(effect_type: int) -> void:
	if not _plugin:
		push_error("Plugin not loaded")
		return
	if _plugin.hasEffectSupport():
		_plugin.vibrateEffect(effect_type)

func primitive(primitive_type: int, intensity: float = 1.0) -> void:
	if not _plugin:
		push_error("Plugin not loaded")
		return
	if _plugin.hasPrimitivesSupport():
		_plugin.vibratePrimitive(primitive_type, clamp(intensity, 0.0, 1.0))

func composition(primitives: Array) -> void:
	if not _plugin:
		push_error("Plugin not loaded")
		return
	var comp = _plugin.Composition.new()
	for p in primitives:
		var intensity = clamp(p.get("intensity", 1.0), 0.0, 1.0)
		var delay = p.get("delay", 0)
		comp.addPrimitive(p["primitive"], intensity, delay)
	comp.vibrate()
