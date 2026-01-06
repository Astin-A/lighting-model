shader_type spatial;

// Colors
uniform vec4 albedo_color : source_color = vec4(0.045, 0.939, 0.296, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.0, 0.1, 0.05, 1.0); // Deep, dark green

// Controls
uniform float shadow_cut : hint_range(-1.0, 1.0) = 0.2;     // Where the main shadow starts
uniform float mid_tone_cut : hint_range(-1.0, 1.0) = 0.3;  // Where it transitions to full light
uniform float smoothness : hint_range(0.0, 0.5) = 0.0;    // The "blur" between bands


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    ALBEDO = albedo_color.rgb;
}

void light() {
    float NdotL = dot(NORMAL, LIGHT);
    
    // Band 1: Deep Shadow to Mid-tone
    float shadow_mask = smoothstep(shadow_cut - smoothness, shadow_cut + smoothness, NdotL);
    
    // Band 2: Mid-tone to Full Light
    float light_mask = smoothstep(mid_tone_cut - smoothness, mid_tone_cut + smoothness, NdotL);
    
    // Combine them: 
    // This creates three distinct areas: Shadow -> (smooth) -> Albedo -> (smooth) -> Light
    vec3 mixed_diffuse = mix(shadow_color.rgb, albedo_color.rgb, shadow_mask);
    mixed_diffuse = mix(mixed_diffuse, albedo_color.rgb * LIGHT_COLOR, light_mask);
    
    // Final output including attenuation (shadows from other objects)
    DIFFUSE_LIGHT += mixed_diffuse * ATTENUATION;
}