shader_type canvas_item;

void fragment() {
	float level = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	float inverted_level = 1.0 - level;
	float value = max(level, inverted_level);
	COLOR = vec4(pow(value, 3), pow(value, 2), value, min(COLOR.a, pow(level, 0.5)));
}
