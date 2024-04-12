uniform sampler2D tex1;
uniform sampler2D tex2;
uniform sampler2D tex3;
uniform vec3 clr0;
uniform vec3 clr1;
uniform vec3 clr2;

void main(){
    vec4 tex_c1 = texture(tex1,uv);
    vec4 tex_c2 = texture(tex2,uv);
    vec4 tex_c3 = texture(tex3,uv);
    outColor.rgb = clr0 * tex_c1.rgb + clr1 * tex_c2.rgb + clr2 * tex_c3.rgb;
    outColor.a = clamp(tex_c1.a*0.333 + tex_c2.a*0.333 + tex_c3.a*0.333, 0, 1);
}