shader_type spatial;

uniform vec4 albedo : source_color = vec4(0.045, 0.939, 0.296, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float metallic : hint_range(0.0, 1.0) = 0.7;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = albedo.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
}

void light() {
	// Basic vectors
	vec3 N = NORMAL;
	vec3 V = VIEW;
	vec3 L = LIGHT;
	vec3 H = normalize(V + L); // Half-vector

	float dotNH = clamp(dot(N, H), 0.0, 1.0);
	float dotNV = clamp(dot(N, V), 0.0, 1.0);
	float dotNL = clamp(dot(N, L), 0.0, 1.0);
	float dotVH = clamp(dot(V, H), 0.0, 1.0);

	float alpha = roughness * roughness;
	float alpha2 = alpha * alpha;

	// 1. D - Normal Distribution Function (Trowbridge-Reitz GGX)
	float denom = (dotNH * dotNH * (alpha2 - 1.0) + 1.0);
	float D = alpha2 / (PI * denom * denom);

	// 2. F - Fresnel Equation (Schlick's Approximation)
	// For dielectrics F0 is approx 0.04, for metals it's the albedo
	vec3 f0 = mix(vec3(0.04), ALBEDO, metallic);
	vec3 F = f0 + (1.0 - f0) * pow(1.0 - dotVH, 5.0);

	// 3. G - Geometry Function (Smith's Schlick-GGX)
	float k = (roughness + 1.0) * (roughness + 1.0) / 8.0;
	float G1V = dotNV / (dotNV * (1.0 - k) + k);
	float G1L = dotNL / (dotNL * (1.0 - k) + k);
	float G = G1V * G1L;

	// Cook-Torrance Specular BRDF formula
	// rs = (D * F * G) / (4 * dotNL * dotNV)
	vec3 numerator = D * F * G;
	float denominator = 4.0 * dotNV * dotNL + 0.0001; // Epsilon to prevent divide by zero
	vec3 specular = numerator / denominator;

	// Energy Conservation: Diffuse is what's left after specular
	vec3 kS = F;
	vec3 kD = (vec3(1.0) - kS) * (1.0 - metallic);

	vec3 diffuse = kD * ALBEDO / PI;

	DIFFUSE_LIGHT += (diffuse + specular) * ATTENUATION * LIGHT_COLOR * dotNL;
}
