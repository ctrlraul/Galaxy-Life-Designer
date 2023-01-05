shader_type canvas_item;

uniform vec2 scale = vec2(1, 1);

void fragment() {
	COLOR = texture(TEXTURE, UV * scale);
	COLOR.a = 0.1;
}
