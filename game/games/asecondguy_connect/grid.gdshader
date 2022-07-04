shader_type canvas_item;

uniform vec2 grid_size;
uniform vec3 grid_color = vec3(0.0, 0.0, 0.0);
uniform float circle_size = .4;

vec2 grid(vec2 uv, float columns, float rows){
	return fract(vec2(uv.x * columns, uv.y * rows));
}

float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

void fragment() {
	vec2 grid = grid(UV, grid_size.x, grid_size.y);
	if (circle(grid, circle_size, 0.005) < .5) {
		return;
	}
//	COLOR = vec4(grid.r, gr.id.g, 0.0, 1.0);
	COLOR.rgb = grid_color;
}
