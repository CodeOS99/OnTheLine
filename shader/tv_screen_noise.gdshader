shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_opaque;

uniform float speed : hint_range(0.1, 10.0) = 3.0;
uniform float intensity : hint_range(0.0, 2.0) = 1.0;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    // Animate the UVs over time to create moving noise
    vec2 uv = UV * 10.0;
    uv.y += TIME * speed;

    // Create layered random noise
    float noise = random(floor(uv * 20.0));
    float noise2 = random(floor(uv * 40.0 + vec2(TIME * 10.0, 0.0)));
    float noiseMix = mix(noise, noise2, 0.5);

    // Convert to grayscale and apply contrast
    float gray = pow(noiseMix, 1.5) * intensity;

    ALBEDO = vec3(gray);
    ALPHA = 1.0;
}
