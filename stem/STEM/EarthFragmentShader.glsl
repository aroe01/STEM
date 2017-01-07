precision mediump float;
uniform sampler2D s_baseMap0;
uniform bool u_hasTexture;
varying vec2 v_texCoord;
varying vec4 v_color;

void main()
{
    vec4 baseColor = u_hasTexture ? texture2D(s_baseMap0, v_texCoord) : vec4(1.0,1.0,1.0,1.0);
    gl_FragColor = v_color * baseColor;
}




