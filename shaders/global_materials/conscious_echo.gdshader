// LARGELY DERIVED FROM https://www.youtube.com/watch?v=rvDo9LvfoVE

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float custom_alpha = 1.0;
uniform float NUM_LAYERS = 1.0;

mat2 Rot(float a) {
	float s=sin(a), c=cos(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

float RandomHash(vec2 p) {
	p = fract(p*vec2(274.36, 627.57));
	p += dot(p, p+86.23);
	return fract(p.x*p.y);
}

vec3 Star(vec2 uv, float flare) {
	vec3 col = vec3(0);
	// Star center
	float d = length(uv);
	float m = .02/d;
	// Star Rays
	float rays = max(0., 1.-abs(uv.x*uv.y * 6000.));
	// Affect color by rays
	col += m;
	col += rays * flare;
	// Rays rotated 45 degrees
	uv *= Rot(3.1415 / 4.);
	rays = max(0., 1.-abs(uv.x*uv.y * 6000.));
	col += rays *.3 * flare;
	
	// Simple fade
	col *= smoothstep(1., .2, d);
	
	return col;
}

vec3 StarLayer(vec2 uv) {
	vec3 col = vec3(0.);
	vec2 gv = fract(uv) - 0.5;
	// Gives an ID (cell number, (x,y)) to each star.
	vec2 id = floor(uv);
	// Iterator recognizes the stars of adjacent cells to add their glow
	for(float y=-1.;y<=1.;y++) {
		for(float x=-1.;x<=1.;x++) {
			vec2 offs = vec2(x,y);
			// Gives the pseudorandom value [0-1] associated with that cell
			float n = RandomHash(id + offs);
			// Random star size (different seed, different value, same input :O)
			float size = fract(n * 696.23);
			
			// Generate the base star
			vec3 star = Star(gv-offs-vec2(n - 0.5, fract(n * 47.) - 0.5), 0.);
			
			// Get a random color per size
			vec3 color = sin(vec3(.2, .3, .9)*fract(n*4579.3) * 16.2831) * .5 + 0.5;
			color *= vec3(0.8,0.5 * (sin(TIME * n * 0.25) * .5 + .5),1.);
			
			
			col += star * size * color;
		}
	}
	return col;
}

void fragment() {
    // Get screen-space coordinates and viewport size
    vec2 uv = FRAGCOORD.xy;
    vec2 viewport_size = vec2(textureSize(SCREEN_TEXTURE, 0));
	vec3 col = vec3(0.2, 0.0, 0.1);
	/// UV SCALING
	float size_y = viewport_size.y;
	// Adjust so that it acts like a square
	viewport_size = vec2(viewport_size.x*2., viewport_size.x*2.);
	// Scale screen to viewport (i.e. shader moves with camera rather than object)
    uv /= viewport_size;
	// Fix an offset issue caused by resizing viewport
	uv.y += 0.5 - size_y / (2.*viewport_size.x);
	uv.x += 0.25;
	// Normalize to centered
	uv = 2. * uv - 1.;
	/// END UV SCALING
	
	// init time with some value passed
	float t = TIME + 1000.;
	
	/// GRID FOR MULTIPLE STARS, with n being number of cells in each row/column
	//uv *= 5.;
	// New UV value for each individual star
	
	for(float i = 0.; i < 1.; i += 1. / NUM_LAYERS) {
		float depth = fract(i*t*0.005);
		
		float scale = mix(20., .5, depth);
		// Avoid the popping when layers reset
		float fade = depth *smoothstep(1., .9, depth);
		col += StarLayer(uv*scale + i * 5565.3)*fade;
	}

	
	// Box edge visualizer
	//if(gv.x>.48 || gv.y>.48) col.r = 1.;

	// BG: 145.0 / 256.0, 29.0 / 256.0, 116.0 / 256.0
	float alpha = custom_alpha;
	if(texture(TEXTURE, UV).rgb != vec3(1.,1.,1.))
	{
		col = texture(TEXTURE, UV).rgb;
		alpha = 1.0;
	}
    COLOR = vec4(col, min(texture(TEXTURE, UV).a, alpha));
}