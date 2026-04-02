shader_type canvas_item;

uniform int hue : hint_range(0, 359);

void fragment() {
	vec2 uv = UV;
	// Invert y so that it renders upside-right
	uv.y = 1. - uv.y;
	
	// Define, hue, saturation, value
	float h = float(hue);
	float s = uv.x;
	float v = uv.y;
	
	// Chroma
	float c = v * s;
	// H' to get HSV region
	float h_1 = h / 60.;
	
	// Idk if this has a name but we need this value
	float x = c * float((1. - abs(mod(h_1, 2) - 1.)));
	
	// Calc temp values that will be adjusted up for final result
	vec3 rgb_prime = vec3(0., 0., 0.);
	     if(0. <= h_1 && h_1 < 1.){rgb_prime = vec3(c, x, 0.);}
	else if(1. <= h_1 && h_1 < 2.){rgb_prime = vec3(x, c, 0.);}
	else if(2. <= h_1 && h_1 < 3.){rgb_prime = vec3(0., c, x);}
	else if(3. <= h_1 && h_1 < 4.){rgb_prime = vec3(0., x, c);}
	else if(4. <= h_1 && h_1 < 5.){rgb_prime = vec3(x, 0., c);}
	else if(5. <= h_1 && h_1 < 6.){rgb_prime = vec3(c, 0., x);}
	
	// Finalls solve for rgb with m
	float m = v - c;
	
	vec3 final_color = vec3(rgb_prime.r + m, rgb_prime.g + m, rgb_prime.b + m);
	
	// Draw SV selector
	COLOR = vec4(final_color.r, final_color.g, final_color.b, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
