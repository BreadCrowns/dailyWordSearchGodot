shader_type canvas_item;

uniform sampler2D my_texture : source_color;
uniform vec4 line_color = vec4(1.0, 0.0, 0.0, 1.0); // red

void fragment() {
    vec4 tex = texture(my_texture, UV);
    float gray = 1.0 - tex.r; // black lines, white bg
    COLOR = vec4(line_color.rgb * gray, gray * line_color.a);
}
