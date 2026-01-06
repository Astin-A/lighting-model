shader_type spatial;

uniform vec4 albedo_color : source_color = vec4(0.045, 0.939, 0.296, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = albedo_color.rgb;
    ALPHA = albedo_color.a;
}

void light() {
    // Standard Lambertian math
    float dot_product = dot(NORMAL, LIGHT);
    float diffuse = max(dot_product, 0.0);

    // Final lighting calculation
    // This multiplies color by the light intensity and shadows
    DIFFUSE_LIGHT += diffuse * ATTENUATION * LIGHT_COLOR;
}
