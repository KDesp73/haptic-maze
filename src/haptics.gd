extends Node
class_name HapticsWrapper

# The singleton/autoload reference to the original plugin
var _plugin: AndroidHaptics = null

func _ready():
	# Assign the autoloaded plugin
	if Engine.has_singleton("GodotAndroidHaptics"):
		_plugin = Engine.get_singleton("GodotAndroidHaptics")
	else:
		push_warning("GodotAndroidHaptics plugin not found!")

# --- PUBLIC METHODS ---

# Vibrate with a simple effect (click, double click, tick, heavy_click)
func effect(effect_type: int) -> void:
	if not _plugin:
		return
	if not OS.has_feature("android"):
		return
	if _plugin.hasEffectSupport():
		_plugin.vibrateEffect(effect_type)
	print("Effect run")

# Vibrate with a primitive (spin, thud, tick, click, low_tick, quick_fall, quick_rise, slow_rise)
func primitive(primitive_type: int, intensity: float = 1.0) -> void:
	if not _plugin:
		return
	if not OS.has_feature("android"):
		return
	if _plugin.hasPrimitivesSupport():
		_plugin.vibratePrimitive(primitive_type, clamp(intensity, 0.0, 1.0))
	print("Primitive run")

# Vibrate a composition of primitives (rich/custom haptics)
func composition(primitives: Array) -> void:
	# primitives: Array of Dictionaries {primitive: int, intensity: float, delay: int}
	if not _plugin:
		return
	if not OS.has_feature("android"):
		return

	var comp = _plugin.Composition.new()
	for p in primitives:
		var intensity = clamp(p.get("intensity", 1.0), 0.0, 1.0)
		var delay = p.get("delay", 0)
		comp.addPrimitive(p["primitive"], intensity, delay)
	comp.vibrate()
	print("Composition run")
