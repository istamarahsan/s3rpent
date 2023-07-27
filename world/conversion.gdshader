shader_type canvas_item;

void vertex() {
    // Calculate the angle of rotation using the 'TIME' variable
    float rotation_angle = TIME; // Adjust the multiplier to control the rotation speed
    
    // Create a 2x2 rotation matrix
    mat2 rotation_matrix = mat2(vec2(cos(rotation_angle), -sin(rotation_angle)), vec2(sin(rotation_angle), cos(rotation_angle)));

    // Apply rotation to the vertex position (position is a built-in variable representing the vertex position)
	VERTEX = vec2(rotation_matrix * VERTEX.xy);
}
