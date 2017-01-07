struct directional_light {
    vec3 direction;
    vec3 halfplane;
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float viewdepend;
};

struct material_properties {
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float specular_exponent;
};

uniform mat4  u_mvpMatrix;
uniform float u_fade;
uniform int u_numLights;
uniform directional_light light[8];
uniform material_properties material;

attribute vec3 a_position;
attribute vec2 a_texCoord0;
attribute vec4 a_color;
attribute vec3 a_normal;

varying vec2 v_texCoord;
varying vec4 v_color;

void main()
{
    v_texCoord = a_texCoord0;
    v_color = vec4(0.0,0.0,0.0,0.0);
    if (u_numLights > 0)
    {
        vec4 ambient = vec4(0.0,0.0,0.0,0.0);
        vec4 diffuse = vec4(0.0,0.0,0.0,0.0);
        for (int ii=0;ii<8;ii++)
        {
            if (ii>=u_numLights)
                break;
            
            vec3 adjNorm = light[ii].viewdepend > 0.0 ? normalize((u_mvpMatrix * vec4(a_normal.xyz, 0.0)).xyz) : a_normal.xzy;
            float ndotl;
            //        float ndoth;
            ndotl = max(0.0, dot(adjNorm, light[ii].direction));
            //        ndotl = pow(ndotl,0.5);
            //        ndoth = max(0.0, dot(adjNorm, light[ii].halfplane));
            ambient += light[ii].ambient;
            diffuse += ndotl * light[ii].diffuse;
        }
        v_color = vec4(ambient.xyz * material.ambient.xyz * a_color.xyz + diffuse.xyz * a_color.xyz,a_color.a) * u_fade;
    } else {
        v_color = a_color * u_fade;
    }
    
    gl_Position = u_mvpMatrix * vec4(a_position,1.0);
}


