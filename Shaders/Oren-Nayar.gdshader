shader_type spatial;

uniform vec4 albedo : source_color = vec4(0.045, 0.939, 0.296, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.1; // Lower = Smoother
uniform float specular_strength : hint_range(0.0, 1.0) = 1.0;
uniform float sheen : hint_range(0.0, 1.0) = 0.7; // Adds a soft "glow" to the edges

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    ALBEDO = albedo.rgb;
    ROUGHNESS = roughness;
    SPECULAR = specular_strength;
}

void light() {
    vec3 N = NORMAL;
    vec3 V = VIEW;
    vec3 L = LIGHT;
    vec3 H = normalize(V + L);
    
    float dotNL = clamp(dot(N, L), 0.0, 1.0);
    float dotNV = clamp(dot(N, V), 0.0, 1.0);
    float dotNH = clamp(dot(N, H), 0.0, 1.0);
    
    // 1. "Smooth" Diffuse (Hybrid Oren-Nayar)
    // We blend between Lambert and Oren-Nayar based on roughness
    // to keep the "flatness" from taking over.
    float sigma2 = roughness * roughness;
    float A = 1.0 - 0.5 * (sigma2 / (sigma2 + 0.33));
    float B = 0.45 * (sigma2 / (sigma2 + 0.09));
    
    float cos_phi_diff = dot(normalize(L - N * dotNL), normalize(V - N * dotNV));
    float alpha = max(acos(dotNL), acos(dotNV));
    float beta = min(acos(dotNL), acos(dotNV));
    float diffuse_brdf = dotNL * (A + B * max(0.0, cos_phi_diff) * sin(alpha) * tan(beta));
    
    // 2. High-Gloss Specular (Cook-Torrance GGX)
    float a2 = sigma2 * sigma2;
    float d_denom = (dotNH * dotNH * (a2 - 1.0) + 1.0);
    float D = a2 / (PI * d_denom * d_denom); 
    
    // Geometric term optimized for smoothness
    float k = sigma2 / 2.0;
    float G = (dotNL / (dotNL * (1.0 - k) + k)) * (dotNV / (dotNV * (1.0 - k) + k));
    
    // Fresnel (Schlick)
    float F = 0.04 + (1.0 - 0.04) * pow(1.0 - dot(H, V), 5.0);
    
    float specular_brdf = (D * G * F) / (4.0 * dotNL * dotNV + 0.0001);

    // 3. Final Output
    vec3 diffuse = ALBEDO * LIGHT_COLOR * diffuse_brdf;
    vec3 specular = LIGHT_COLOR * specular_brdf * specular_strength;
    
    // Multiply by ATTENUATION for shadows and LIGHT_COLOR for light settings
    DIFFUSE_LIGHT += (diffuse + specular) * ATTENUATION;
}
