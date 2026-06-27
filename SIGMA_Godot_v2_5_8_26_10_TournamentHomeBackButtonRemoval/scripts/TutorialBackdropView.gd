extends Control
class_name TutorialBackdropView

# Full-screen tutorial intro backdrop. It intentionally blocks clicks behind the
# tutorial card until a live board mission begins.

var bg_color: Color = Color("#010204", 0.94)
var accent_gold: Color = Color("#F2C14E")
var accent_cyan: Color = Color("#28E0FF")
var accent_purple: Color = Color("#7C3AED")
var accent_green: Color = Color("#22C55E")
var accent_orange: Color = Color("#FF7A18")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func _draw() -> void:
	var r: Rect2 = Rect2(Vector2.ZERO, size)
	draw_rect(r, bg_color, true)
	var t: float = float(Time.get_ticks_msec()) / 1000.0
	var center: Vector2 = size * 0.5
	var max_r: float = max(size.x, size.y)
	for i in range(7):
		var radius: float = max_r * (0.14 + float(i) * 0.095)
		var alpha: float = max(0.0, 0.075 - float(i) * 0.007)
		draw_arc(center, radius, 0.0, TAU, 96, Color("#10305B", alpha), 1.0)

	var cols: Array[Color] = [accent_gold, accent_cyan, accent_purple, accent_green, accent_orange]
	for i in range(26):
		var col: Color = cols[i % cols.size()]
		var px: float = fmod(float(i * 73) + t * (8.0 + float(i % 4) * 1.6), max(1.0, size.x + 90.0)) - 45.0
		var py: float = fmod(float(i * 127) - t * (10.0 + float(i % 5) * 1.8), max(1.0, size.y + 100.0)) - 50.0
		px += sin(t * 0.35 + float(i) * 0.71) * 10.0
		py += cos(t * 0.28 + float(i) * 0.63) * 8.0
		var pos: Vector2 = Vector2(px, py)
		var scale: float = 8.0 + float(i % 5) * 4.0
		var rot: float = t * (0.12 + float(i % 6) * 0.035) + float(i) * 0.41
		var a: float = 0.045 + 0.020 * (0.5 + 0.5 * sin(t * 0.9 + float(i)))
		draw_circle(pos, scale * 1.5, Color(col.r, col.g, col.b, a * 0.45))
		match i % 6:
			0:
				_draw_poly(pos, scale, 4, Color(col.r, col.g, col.b, a + 0.045), rot, true)
			1:
				_draw_poly(pos, scale, 6, Color(col.r, col.g, col.b, a + 0.040), rot, true)
			2:
				_draw_poly(pos, scale, 3, Color(col.r, col.g, col.b, a + 0.040), rot, true)
			3:
				draw_arc(pos, scale, rot, rot + TAU, 36, Color(col.r, col.g, col.b, a + 0.050), 1.2)
				draw_circle(pos, scale * 0.42, Color(col.r, col.g, col.b, a * 0.45))
			4:
				_draw_chevron(pos, scale, Color(col.r, col.g, col.b, a + 0.040), rot)
			_:
				_draw_cross(pos, scale, Color(col.r, col.g, col.b, a + 0.035), rot)

	for j in range(22):
		var tt: float = t * (0.11 + float(j % 5) * 0.015) + float(j) * 0.63
		var star_pos: Vector2 = Vector2(
			fmod(float(j * 97) + sin(tt) * 18.0, max(1.0, size.x)),
			fmod(float(j * 151) + cos(tt * 0.9) * 22.0, max(1.0, size.y))
		)
		draw_circle(star_pos, 0.9 + 0.4 * sin(tt * 1.8), Color("#F2C14E", 0.06 + 0.04 * sin(tt) * sin(tt)))

func _draw_poly(center: Vector2, radius: float, sides: int, col: Color, rotation: float, filled: bool) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(sides):
		var ang: float = TAU * float(i) / float(sides) - PI * 0.5 + rotation
		pts.append(center + Vector2(cos(ang), sin(ang)) * radius)
	if filled:
		draw_colored_polygon(pts, Color(col.r, col.g, col.b, col.a * 0.12))
	_draw_closed(pts, col, 1.2)

func _draw_chevron(center: Vector2, radius: float, col: Color, rotation: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		center + _rot(Vector2(-radius * 0.8, -radius * 0.2), rotation),
		center + _rot(Vector2(0, radius * 0.55), rotation),
		center + _rot(Vector2(radius * 0.8, -radius * 0.2), rotation),
	])
	_draw_closed(pts, col, 1.2)

func _draw_cross(center: Vector2, radius: float, col: Color, rotation: float) -> void:
	var a: Vector2 = center + _rot(Vector2(-radius, 0), rotation)
	var b: Vector2 = center + _rot(Vector2(radius, 0), rotation)
	var c: Vector2 = center + _rot(Vector2(0, -radius), rotation)
	var d: Vector2 = center + _rot(Vector2(0, radius), rotation)
	draw_line(a, b, col, 1.1)
	draw_line(c, d, col, 1.1)
	draw_arc(center, radius * 0.46, rotation, rotation + TAU, 24, Color(col.r, col.g, col.b, col.a * 0.7), 1.0)

func _draw_closed(points: PackedVector2Array, col: Color, width: float) -> void:
	if points.size() < 2:
		return
	for i in range(points.size()):
		draw_line(points[i], points[(i + 1) % points.size()], col, width)

func _rot(v: Vector2, angle: float) -> Vector2:
	var c: float = cos(angle)
	var s: float = sin(angle)
	return Vector2(v.x * c - v.y * s, v.x * s + v.y * c)
