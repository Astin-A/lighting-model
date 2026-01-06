shader_type spatial;

uniform vec4 albedo_color : source_color = vec4(0.045, 0.939, 0.296, 1.0);
uniform float glossiness : hint_range(1.0, 512.0) = 64.0;
uniform float specular_intensity : hint_range(0.0, 5.0) = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    ALBEDO = albedo_color.rgb;
}

void light() {
    // 1. SAFETY: Normalize inputs to prevent light "leaking" or artifacts
    vec3 N = normalize(NORMAL);
    vec3 L = normalize(LIGHT);
    vec3 V = normalize(VIEW);

    // 2. DIFFUSE (Lambertian)
    float n_dot_l = clamp(dot(N, L), 0.0, 1.0);

    // 3. BLINN-PHONG SPECULAR (Halfway Vector)
    // The Halfway vector is the standard for modern "stable" shaders
    vec3 H = normalize(L + V);
    float n_dot_h = clamp(dot(N, H), 0.0, 1.0);

    // Apply power for sharpness and multiply by intensity
    float spec = pow(n_dot_h, glossiness) * specular_intensity;

    // 4. FINAL COMPOSITION
    // We use Godot's built-in LIGHT_COLOR and ATTENUATION (for shadows)
    vec3 light_color_final = LIGHT_COLOR * ATTENUATION;

    // Output diffuse and specular separately for the engine to blend
    DIFFUSE_LIGHT += ALBEDO * n_dot_l * light_color_final;
    SPECULAR_LIGHT += vec3(spec) * light_color_final;
}
