shader_type canvas_item;

uniform vec4 line_color = vec4(1.0, 0.0, 0.0, 1.0); // default line color

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float gray = 1.0 - tex.r; // black lines, white bg
    COLOR = vec4(line_color.rgb * gray, gray * line_color.a);
}
