extends Control

# Lightweight procedural FX layer for the SIGMA main menu.
# It follows the same responsive draw rect as the static background art.
# No video, no sprite sequence, no extra texture memory.

var background_rect: Rect2 = Rect2()
var fx_time: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func set_background_rect(rect: Rect2) -> void:
	background_rect = rect
	queue_redraw()

func _process(delta: float) -> void:
	if not visible:
		return
	fx_time = fmod(fx_time + delta, 10000.0)
	queue_redraw()

func _draw() -> void:
	if background_rect.size.x <= 1.0 or background_rect.size.y <= 1.0:
		return
	var bg: Rect2 = background_rect
	var shortest: float = min(bg.size.x, bg.size.y)
	var pulse: float = 0.5 + 0.5 * sin(fx_time * 2.1)
	var slow_pulse: float = 0.5 + 0.5 * sin(fx_time * 1.1)

	# Very subtle premium shimmer across the responsive background image.
	_draw_shimmer_sweep(bg, shortest, pulse)
	_draw_soft_energy_lines(bg, shortest, slow_pulse)

	# Center diamonds in the top and bottom menu art.
	var top_diamond: Vector2 = bg.position + Vector2(bg.size.x * 0.50, bg.size.y * 0.027)
	var bottom_diamond: Vector2 = bg.position + Vector2(bg.size.x * 0.50, bg.size.y * 0.972)
	var diamond_radius: float = clamp(shortest * 0.035, 12.0, 34.0)
	_draw_center_diamond_pulse(top_diamond, diamond_radius, pulse, Color("#F2C14E"))
	_draw_center_diamond_pulse(bottom_diamond, diamond_radius * 1.04, 1.0 - slow_pulse, Color("#D4AF37"))

func _draw_shimmer_sweep(bg: Rect2, shortest: float, pulse: float) -> void:
	var cycle: float = fmod(fx_time * 0.115, 1.0)
	var sweep_x: float = bg.position.x - bg.size.x * 0.34 + cycle * bg.size.x * 1.68
	var band: float = clamp(shortest * 0.055, 18.0, 54.0)
	var skew: float = bg.size.y * 0.22
	var poly: PackedVector2Array = PackedVector2Array([
		Vector2(sweep_x - band, bg.position.y),
		Vector2(sweep_x + band * 0.36, bg.position.y),
		Vector2(sweep_x + band * 0.36 + skew, bg.position.y + bg.size.y),
		Vector2(sweep_x - band + skew, bg.position.y + bg.size.y),
	])
	_draw_colored_polygon_clipped(poly, bg, Color("#79D8FF", 0.028 + pulse * 0.014))

	var gold_poly: PackedVector2Array = PackedVector2Array([
		Vector2(sweep_x - band * 0.24, bg.position.y),
		Vector2(sweep_x + band * 0.12, bg.position.y),
		Vector2(sweep_x + band * 0.12 + skew, bg.position.y + bg.size.y),
		Vector2(sweep_x - band * 0.24 + skew, bg.position.y + bg.size.y),
	])
	_draw_colored_polygon_clipped(gold_poly, bg, Color("#F2C14E", 0.020 + pulse * 0.010))

func _draw_soft_energy_lines(bg: Rect2, shortest: float, pulse: float) -> void:
	var center: Vector2 = bg.get_center()
	var radius: float = shortest * 0.22
	for i in range(5):
		var angle: float = fx_time * (0.10 + float(i) * 0.012) + float(i) * TAU / 5.0
		var a: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius * 0.72
		var b: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius * 1.12
		draw_line(a, b, Color("#00D1FF", 0.020 + pulse * 0.020), 1.1)
	for s in range(10):
		var t: float = fmod(fx_time * 0.038 + float(s) * 0.137, 1.0)
		var x: float = bg.position.x + bg.size.x * (0.10 + 0.80 * fmod(float(s) * 0.271 + t * 0.08, 1.0))
		var y: float = bg.position.y + bg.size.y * (0.16 + 0.68 * fmod(float(s) * 0.419 + t, 1.0))
		var sparkle_color: Color = Color("#F2C14E", 0.035 + pulse * 0.022) if s % 2 == 0 else Color("#00D1FF", 0.035 + pulse * 0.018)
		draw_circle(Vector2(x, y), clamp(shortest * 0.004, 1.5, 3.2), sparkle_color)

func _draw_center_diamond_pulse(center: Vector2, radius: float, pulse: float, base_color: Color) -> void:
	var glow_alpha: float = 0.10 + pulse * 0.13
	var ring_alpha: float = 0.18 + pulse * 0.24
	draw_circle(center, radius * (2.65 + pulse * 0.35), Color(base_color.r, base_color.g, base_color.b, glow_alpha * 0.30))
	draw_circle(center, radius * (1.72 + pulse * 0.25), Color("#00D1FF", 0.035 + pulse * 0.030))
	draw_arc(center, radius * (1.42 + pulse * 0.26), 0.0, TAU, 48, Color(base_color.r, base_color.g, base_color.b, ring_alpha), 2.0)
	draw_arc(center, radius * (2.10 + pulse * 0.32), 0.0, TAU, 56, Color("#00D1FF", 0.08 + pulse * 0.08), 1.2)

	var diamond: PackedVector2Array = PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius, 0),
	])
	draw_colored_polygon(diamond, Color(base_color.r, base_color.g, base_color.b, 0.075 + pulse * 0.075))
	draw_polyline(PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius, 0),
		center + Vector2(0, -radius),
	]), Color(base_color.r, base_color.g, base_color.b, 0.42 + pulse * 0.30), 1.8)

func _clip_polygon_edge(points: Array, edge: String, value: float) -> Array:
	var output: Array = []
	if points.is_empty():
		return output
	var previous: Vector2 = points[points.size() - 1]
	var previous_inside: bool = _point_inside_clip_edge(previous, edge, value)
	for current_value in points:
		var current: Vector2 = current_value
		var current_inside: bool = _point_inside_clip_edge(current, edge, value)
		if current_inside:
			if not previous_inside:
				output.append(_clip_edge_intersection(previous, current, edge, value))
			output.append(current)
		elif previous_inside:
			output.append(_clip_edge_intersection(previous, current, edge, value))
		previous = current
		previous_inside = current_inside
	return output

func _point_inside_clip_edge(point: Vector2, edge: String, value: float) -> bool:
	match edge:
		"left":
			return point.x >= value
		"right":
			return point.x <= value
		"top":
			return point.y >= value
		"bottom":
			return point.y <= value
	return true

func _clip_edge_intersection(a: Vector2, b: Vector2, edge: String, value: float) -> Vector2:
	var delta: Vector2 = b - a
	if edge == "left" or edge == "right":
		if abs(delta.x) <= 0.0001:
			return Vector2(value, a.y)
		var t_x: float = clamp((value - a.x) / delta.x, 0.0, 1.0)
		return a + delta * t_x
	if abs(delta.y) <= 0.0001:
		return Vector2(a.x, value)
	var t_y: float = clamp((value - a.y) / delta.y, 0.0, 1.0)
	return a + delta * t_y

func _clip_polygon_to_rect(points: PackedVector2Array, clip_rect: Rect2) -> PackedVector2Array:
	var clipped: Array = []
	for point_value in points:
		clipped.append(point_value)
	var left: float = clip_rect.position.x
	var right: float = clip_rect.position.x + clip_rect.size.x
	var top: float = clip_rect.position.y
	var bottom: float = clip_rect.position.y + clip_rect.size.y
	clipped = _clip_polygon_edge(clipped, "left", left)
	clipped = _clip_polygon_edge(clipped, "right", right)
	clipped = _clip_polygon_edge(clipped, "top", top)
	clipped = _clip_polygon_edge(clipped, "bottom", bottom)
	var result: PackedVector2Array = PackedVector2Array()
	for clipped_point in clipped:
		result.append(clipped_point)
	return result

func _draw_colored_polygon_clipped(points: PackedVector2Array, clip_rect: Rect2, color: Color) -> void:
	var clipped: PackedVector2Array = _clip_polygon_to_rect(points, clip_rect)
	if clipped.size() >= 3:
		draw_colored_polygon(clipped, color)
