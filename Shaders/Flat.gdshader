shader_type spatial;

uniform vec4 albedo_color : source_color = vec4(0.045, 0.939, 0.296, 1.0);
uniform float glossiness : hint_range(1.0, 1024.0) = 32.0;
uniform float specular_strength : hint_range(0.0, 1.0) = 0.5;

varying vec3 v_normal;

void vertex() {
    // Pass the normal to the fragment shader
    v_normal = NORMAL;
}

void fragment() {
    ALBEDO = albedo_color.rgb;

    // FORCED FLAT SHADING:
    // This trick calculates the normal based on the screen-space derivative
    // of the position, giving every triangle a flat, faceted face.
    vec3 face_normal = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
    NORMAL = face_normal;
}

void light() {
    // 1. LAMBERT DIFFUSE
    float dot_product = dot(NORMAL, LIGHT);
    float diffuse = max(dot_product, 0.0);

    // 2. BLINN-PHONG SPECULAR
    // H is the halfway vector between the Light direction and the View (camera) direction
    vec3 halfway_vector = normalize(LIGHT + VIEW);
    float blinn_term = dot(NORMAL, halfway_vector);
    blinn_term = max(blinn_term, 0.0);

    // Raise to a power for "tightness" of the highlight
    float specular = pow(blinn_term, glossiness) * specular_strength;

    // 3. COMBINE
    vec3 lighting = (diffuse + specular) * ATTENUATION * LIGHT_COLOR;
    DIFFUSE_LIGHT += lighting;
}
