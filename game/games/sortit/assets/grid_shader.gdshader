shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform float specular : hint_range(0, 1);
uniform float metallic : hint_range(0, 1);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform float gridSize;
uniform float lineWidth : hint_range(0, 1);
uniform vec4 floorColor : hint_color;
uniform float floorRoughness;
uniform vec4 lineColor : hint_color;
uniform float lineRoughness;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void fragment() {
	vec2 pos = fract(UV * gridSize);
	if (pos.x < lineWidth || pos.y < lineWidth) {
		ALBEDO = lineColor.rgb;
		ROUGHNESS = lineRoughness;
	} else {
		ALBEDO = floorColor.rgb;
		ROUGHNESS = floorRoughness;
	}
	METALLIC = metallic;
	SPECULAR = specular;
}
