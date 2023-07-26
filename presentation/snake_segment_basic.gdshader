shader_type canvas_item;

uniform vec4 flash_color: source_color = vec4(1);
uniform float degree: hint_range(0.0, 1.0, 0.1);

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	vec3 result = mix(source.rgb, flash_color.rgb, degree * flash_color.a);
	COLOR = vec4(result, source.a);
}
