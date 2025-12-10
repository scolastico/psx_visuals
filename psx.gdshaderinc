
const float PSX_DITHER_MATRIX[16] = float[](
    0.0,  8.0,  2.0, 10.0,
    12.0, 4.0, 14.0, 6.0,
    3.0, 11.0, 1.0,  9.0,
    15.0, 7.0, 13.0, 5.0
);

vec4 dither(vec4 color, vec2 uv, int depth) {
	ivec2 p = ivec2(floor(uv));
	int xi = int(p.x & 3); // mod 4
	int yi = int(p.y & 3); // mod 4
	int index = xi + yi * 4;
	
	float norm = PSX_DITHER_MATRIX[index] / 16.0;
	float bit_levels = float((1 << depth) - 1);
	return floor((color + norm / bit_levels) * bit_levels) / bit_levels;
}

vec3 snap(vec3 vertex, mat4 matrix, float scale) {
	if (scale == 0.0) return vertex;
	
	vec3 v = (matrix * vec4(vertex, 1.0)).xyz;
	v = round(v / scale) * scale;
	return (inverse(matrix) * vec4(v, 1.0)).xyz;
}
