precision mediump float;
uniform sampler2D s_baseMap0;
uniform bool u_hasTexture;
varying vec2 v_texCoord;
varying vec4 v_color;


float getBrightness(vec4 color);

void applyEffect() {
    float brightness = getBrightness(gl_FragColor);
    gl_FragColor = vec4(brightness, brightness, brightness, gl_FragColor.a);
    // gl_FragColor = vec4(0.0, brightness, 0.0, gl_FragColor.a);
    //  gl_FragColor = vec4(brightness * vec3(0.5, 1.0, 0.5), gl_FragColor.a);
}

float threeway_max(float a, float b, float c) {
    return max(a, max(b, c));
}

float threeway_min(float a, float b, float c) {
    return min(a, min(b, c));
}

/**
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
 */

void rgbToHsl(float r, float g, float b, float hsl[3] ) {
    //void rgbToHsl(float r, float g, float b) {
    float rd = r/255.0;
    float gd = g/255.0;
    float bd = b/255.0;
    float max = threeway_max(rd, gd, bd);
    float min = threeway_min(rd, gd, bd);
    float h, s, l = (max + min) / 2.0;
    
    if (max == min) {
        h = s = 0.0; // achromatic
    } else {
        float d = max - min;
        s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min);
        if (max == rd) {
            h = (gd - bd) / d + (gd < bd ? 6.0 : 0.0);
        } else if (max == gd) {
            h = (bd - rd) / d + 2.0;
        } else if (max == bd) {
            h = (rd - gd) / d + 4.0;
        }
        h /= 6.0;
    }
    hsl[0] = h;
    hsl[1] = s;
    hsl[2] = l;
}

/*
 vec3 rgb2hsv(vec3 c)
 {
 vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
 vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
 vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
 
 float d = q.x - min(q.w, q.y);
 float e = 1.0e-10;
 return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
 }
 
 vec3 hsv2rgb(vec3 c)
 {
 vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
 vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
 return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
 }
 void main() {
 vec4 textureColor = texture2D(s_baseMap0, v_texCoord);
 vec3 fragRGB = textureColor.rgb;
 vec3 fragHSV = rgb2hsv(fragRGB).xyz;
 fragHSV.x += v_color.x / 360.0;
 fragHSV.yz *= v_color.yz;
 fragHSV.xyz = mod(fragHSV.xyz, 1.0);
 fragRGB = hsv2rgb(fragHSV);
 gl_FragColor = vec4(fragRGB, textureColor.w);
 }
 */

void main()
{
    
    //    gl_FragColor = v_color * color;
    
    
    vec4 baseColor = u_hasTexture ? texture2D(s_baseMap0, v_texCoord) : vec4(1.0,1.0,1.0,1.0);
    //    vec4 baseColor = texture2D(s_baseMap0, v_texCoord) * v_color * vec4(0.5, 0.5, 0.5, 1.0);
    gl_FragColor = v_color * baseColor;
    
    /*
     vec4 color = texture2D(s_baseMap0, v_texCoord);
     float inverted = 1.0 - color.r;
     vec4 inverted_vec = vec4( vec3(inverted), 1.0) * vec4( vec3(inverted), 1.0);
     gl_FragColor = clamp(inverted_vec, 0.0, 1.0);
     */
    
    /*
     vec4 color = texture2D(s_baseMap0, v_texCoord);
     float inverted = 1.0 - color.r;
     vec4 inverted_vec = vec4( vec3(inverted), 1.0) * vec4( vec3(inverted), 1.0)  * vec4( vec3(inverted), 1.0);
     gl_FragColor = clamp(inverted_vec, 0.0, 1.0);
     */
    
    /*
     vec4 color = texture2D(s_baseMap0, v_texCoord);
     float luminance = color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
     gl_FragColor = vec4(luminance, luminance, luminance, 1.0);
     */
    
    /*
     vec4 color = texture2D(s_baseMap0, v_texCoord);
     color.rgb = vec3((color.r + color.g + color.b) / 3.0);
     gl_FragColor = vec4(color.rgb, 1);
     */
    
    
    
    
    
    //    gl_FragColor = (v_color * color) * vec4(0.0, 1.0, 1.0, 1.0);
    
    /*
     if(gl_FragColor.r > 0.98 && gl_FragColor.g > 0.98 && gl_FragColor.b > 0.98) {
     gl_FragColor = vec4(0.0/255.0, 0.0/255.0, 86.0/255.0, 1.0);
     //        gl_FragColor = v_color * color * v_color * v_color;
     } else if(gl_FragColor.r > 0.96 && gl_FragColor.g > 0.96 && gl_FragColor.b > 0.96) {
     gl_FragColor = vec4(1.0/255.0, 21.0/255.0, 144.0/255.0, 1.0);
     
     } else if(gl_FragColor.r > 0.94 && gl_FragColor.g > 0.94 && gl_FragColor.b > 0.94) {
     gl_FragColor = vec4(0.0/255.0, 74.0/255.0, 179.0/255.0, 1.0);
     } else if(gl_FragColor.r > 0.92 && gl_FragColor.g > 0.92 && gl_FragColor.b > 0.92) {
     gl_FragColor = vec4(0.0/255.0, 120.0/255.0, 215.0/255.0, 1.0);
     } else if(gl_FragColor.r > 0.90 && gl_FragColor.g > 0.90 && gl_FragColor.b > 0.90) {
     gl_FragColor = vec4(0.0/255.0, 220.0/255.0, 255.0/255.0, 1.0);
     */
    
    //    float val = 0.905;
    //    float val2 = 0.88;
    
    //    gl_FragColor = step( 0.5, vMask.r ) * vColor_1 + ( 1.0 - step( 0.5, vMask.r ) ) * vColor_2
    
    float val = 0.7;
    float val2 = 0.67;
    float val3 = 0.15;
    
    /*
     if(gl_FragColor.r > val3 && gl_FragColor.g > val3 && gl_FragColor.b > val3) {
     gl_FragColor = vec4(0.0/255.0, 0.0/255.0, 86.0/255.0, 1.0);
     } else {
     gl_FragColor = vec4(255.0/255.0, 0.0/255.0, 0.0/255.0, 1.0);
     }
     */
    
    /*
     if(gl_FragColor.r > val && gl_FragColor.g > val && gl_FragColor.b > val) {
     //        gl_FragColor = v_color * color + v_color * color + v_color * color + v_color * vec4(0.0, 1.0, 1.0, 1.0);
     gl_FragColor = v_color * color + v_color * vec4(0.4, 0.7, 0.7, 1.0);
     
     
     //        gl_FragColor = v_color * color + v_color * color + v_color * color + v_color * color + v_color * color; // + v_color * color; // + v_color * color + v_color * color;
     //      gl_FragColor = vec4(0.0/255.0, 220.0/255.0, 255.0/255.0, 1.0);
     
     } else if(gl_FragColor.r > val2 && gl_FragColor.g > val2 && gl_FragColor.b > val2) {
     gl_FragColor = vec4(0.0/255.0, 0.0/255.0, 0.0/255.0, 0.7);
     //gl_FragColor = vec4(255.0/255.0, 0.0/255.0, 0.0/255.0, 1.0);
     
     } else {
     gl_FragColor = v_color * color;
     //        gl_FragColor = vec4(255.0/255.0, 0.0/255.0, 0.0/255.0, 1.0);
     
     //        gl_FragColor = v_color * color + v_color * vec4(0.4, 0.1, 0.03, 1.0);
     
     
     }
     */
    
    
    //    gl_FragColor = ( length(gl_FragCoord.xy) < 0.5 ) ? vec4(1,1,1,1) : vec4(0,0,0,1);
    
    
    
    //    applyEffect();
    
    float hsl[3];
    rgbToHsl(gl_FragColor.r , gl_FragColor.g, gl_FragColor.b, hsl );
    //    gl_FragColor = vec4(hsl[0], hsl[1], hsl[2], gl_FragColor.a);
    
    
    if(hsl[2] < 0.09) {
        //        gl_FragColor = vec4(0.0, 0.0, 0.5, 1.0);
        //        gl_FragColor = vec4(gl_FragColor.r, gl_FragColor.g, gl_FragColor.b, 1.0);
    }
    
    
    if(hsl[0] < 0.114 && hsl[2] < 0.09) {
        //                gl_FragColor = vec4(0.0, 0.0, 0.5, 1.0);
        //        gl_FragColor = vec4(gl_FragColor.r, gl_FragColor.g, gl_FragColor.b, 1.0);
        
        //        applyEffect();
        
    }
    
    
}


float getBrightness(vec4 color) {
    return color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
}





