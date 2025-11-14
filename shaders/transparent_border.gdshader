shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float brightness = length(color.rgb);
    if (brightness < threshold) {color.a = 0.0;}
    COLOR = color;
}