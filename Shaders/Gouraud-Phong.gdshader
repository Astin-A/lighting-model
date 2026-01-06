shader_type spatial;


uniform vec4 albedo_color : source_color = vec4(0.045, 0.939, 0.296, 1.0);
uniform float shininess : hint_range(0.1, 128.0) = 64.0;
uniform float specular_strength : hint_range(0.0, 2.0) = 1.0;

// Varying to pass the calculated lighting from vertex to fragment
varying vec3 v_lighting;


void vertex() {
    // 1. Setup vectors in View Space
    vec3 normal = normalize(MODELVIEW_NORMAL_MATRIX * NORMAL);
    vec3 vertex_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // In Godot spatial shaders, lights are handled differently,
    // but for "True" Gouraud, we simulate a fixed light direction here
    // or use a simplified directional light vector.
    vec3 light_dir = normalize(vec3(0.5, 1.0, 0.5));
    vec3 view_dir = normalize(-vertex_pos);

    // 2. PHONG DIFFUSE (The "Lambert" component of Phong)
    float diff = max(dot(normal, light_dir), 0.0);

    // 3. PHONG SPECULAR
    // Reflect the light across the normal
    vec3 reflect_dir = reflect(-light_dir, normal);
    float spec = pow(max(dot(view_dir, reflect_dir), 0.0), shininess);

    // 4. COMBINE
    // We calculate the intensity here so the fragment shader just displays it
    v_lighting = (diff + (spec * specular_strength)) * vec3(1.0);
}

void fragment() {
    // The GPU interpolates v_lighting between vertices automatically
    ALBEDO = albedo_color.rgb * v_lighting;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
