shader_type canvas_item;

uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float smoothness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - smoothstep(0.8, 0.8 - smoothness, dist);
    COLOR = mix(vec4(0.0), color, vignette * intensity);
}
