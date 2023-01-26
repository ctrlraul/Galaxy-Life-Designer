shader_type canvas_item;

uniform vec2 scale = vec2(1, 1);
uniform vec2 offset = vec2(0);

const vec2 isometricScale = vec2(1, 2);
const float quarterPI = PI * 0.25;

//vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
//
//	float cosa = cos(rotation);
//	float sina = sin(rotation);
//
//	uv -= pivot;
//	uv = vec2(
//		cosa * uv.x - sina * uv.y,
//		cosa * uv.y + sina * uv.x 
//	);
//	uv += pivot;
//
//	return uv;
//}

vec2 rotateUV(vec2 uv, float rotation) {
	float cosa = cos(rotation);
	float sina = sin(rotation);
	return vec2(
		cosa * uv.x - sina * uv.y,
		cosa * uv.y + sina * uv.x 
	);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	uv -= vec2(0.5); // Make scaling relative to screen center
	uv = screen_uv_to_sdf(uv);
	uv = rotateUV((uv + offset) * isometricScale, quarterPI) * scale;
	COLOR = texture(TEXTURE, uv);
	COLOR.a = 0.1; // Needed here because modulate isn't working with shaders
}
