#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

// Vertex attributes
layout (location = 0) in vec4 inPos;
layout (location = 1) in vec3 inColor;
layout (location = 2) in vec3 inNormal;

// Instanced attributes
layout (location = 4) in vec3 instancePos;
layout (location = 5) in vec3 instanceRot;
layout (location = 6) in float instanceScale;
layout (location = 7) in int instanceTexIndex;

layout (binding = 0) uniform UBO 
{
	mat4 projection;
	mat4 view;
	float time;
} ubo;

layout (location = 0) out vec3 outNormal;
layout (location = 1) out vec3 outColor;
layout (location = 2) out vec3 outEyePos;
layout (location = 3) out vec3 outLightVec;

void main() 
{
	outColor = inColor;
	mat4 mx, my, mz;
	
	// rotate around x
    float s = sin(instanceRot.x);
    float c = cos(instanceRot.x);

    mx[0] = vec4(c, s, 0.0, 0.0);
    mx[1] = vec4(-s, c, 0.0, 0.0);
    mx[2] = vec4(0.0, 0.0, 1.0, 0.0);
    mx[3] = vec4(0.0, 0.0, 0.0, 1.0);	
	
	// rotate around y
    s = sin(instanceRot.y + ubo.time);
    c = cos(instanceRot.y + ubo.time);

	my[0] = vec4(c, 0.0, s, 0.0);
    my[1] = vec4(0.0, 1.0, 0.0, 0.0);
    my[2] = vec4(-s, 0.0, c, 0.0);
    my[3] = vec4(0.0, 0.0, 0.0, 1.0);	
	
	// rot around z
    s = sin(instanceRot.z);
    c = cos(instanceRot.z);	
	
    mz[0] = vec4(1.0, 0.0, 0.0, 0.0);
    mz[1] = vec4(0.0, c, s, 0.0);
    mz[2] = vec4(0.0, -s, c, 0.0);
    mz[3] = vec4(0.0, 0.0, 0.0, 1.0);	
	
	mat4 rotMat = mz * my * mx;

    //outNormal = inNormal;
    //vec4 pos = inPos;
	outNormal = inNormal * mat3(rotMat);
	vec4 pos = vec4((inPos.xyz * instanceScale) + instancePos, 1.0) * rotMat;

	outEyePos = vec3(ubo.view * pos);
	
	gl_Position = ubo.projection * ubo.view * pos;
	
	vec4 lightPos = vec4(0.0, 0.0, 0.0, 1.0) * ubo.view;
	outLightVec = normalize(lightPos.xyz - outEyePos);
}