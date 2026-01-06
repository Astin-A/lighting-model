shader_type spatial;

uniform vec4 albedo_color : source_color = vec4(0.045, 0.939, 0.296, 1.0);
uniform float shininess : hint_range(1.0, 256.0) = 64.0;
uniform float specular_strength : hint_range(0.0, 5.0) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// We pass the base color to the lighting processor
    ALBEDO = albedo_color.rgb;
}

void light() {
    // 1. SAFETY: Normalize everything
    // If these aren't normalized, the dot products can exceed 1.0 or go negative
    vec3 N = normalize(NORMAL);
    vec3 L = normalize(LIGHT);
    vec3 V = normalize(VIEW);

    // 2. DIFFUSE
    float n_dot_l = dot(N, L);
    // Use clamp to prevent negative light values which "break" pixels
    float diffuse_intensity = clamp(n_dot_l, 0.0, 1.0);

    // 3. PHONG SPECULAR
    vec3 R = reflect(-L, N);
    float v_dot_r = dot(V, R);
    // We must clamp the base before the power function to avoid NaN errors
    float spec = pow(clamp(v_dot_r, 0.0, 1.0), shininess) * specular_strength;

    // 4. THE GODOT 4 FIX: Energy & Light Color
    // We add DIFFUSE_LIGHT and SPECULAR_LIGHT separately
    // This allows Godot's internal engine to combine them with shadows (ATTENUATION)

    vec3 light_contribution = LIGHT_COLOR * ATTENUATION;

    DIFFUSE_LIGHT += ALBEDO * diffuse_intensity * light_contribution;
    SPECULAR_LIGHT += vec3(spec) * light_contribution;
}
