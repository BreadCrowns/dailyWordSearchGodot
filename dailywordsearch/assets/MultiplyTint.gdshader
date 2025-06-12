shader_type canvas_item;

uniform vec4 line_color = vec4(1.0, 0.0, 0.0, 1.0); // default line color

// Calculates line intensity that works for textures imported from both PNG and
// SVG files. PNG assets typically have opaque backgrounds with black lines,
// while SVG assets are imported with transparency. We use the texture's alpha
// when transparency is present, otherwise fall back to the red channel.
void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float line = tex.a < 1.0 ? tex.a : (1.0 - tex.r);
    COLOR = vec4(line_color.rgb * line, line * line_color.a);
}
