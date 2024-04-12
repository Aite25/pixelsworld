version3()
--[[
Offset Frames - slider(0):1 -> channels offset frames, frame gap of channels.
Other Channels Alpha - slider(1):1 -> alpha of offset channels.
Current Color - checkbox(0):1 -> current channel color on.
Same Color Check - checkbox(1):0 -> If all three channels are the same color in a pixel, the original color is forced to be displayed.
Previous - color(0):[#FF0000] -> previous channel color.
Current - color(1):[#00FF00] -> current channel color.
Next - color(2):[#0000FF] -> next channel color.
==========================================
Select a layer to Start!

Timewarp Color by Aite25
--]]

content = [==[
uniform sampler2D tex1;
uniform sampler2D tex2;
uniform sampler2D tex3;
uniform vec3 clr0;
uniform vec3 clr1;
uniform vec3 clr2;
uniform float _S1;
uniform float _Check0;
uniform float _Check1;

void main(){
    vec4 tex_c1 = texture(tex1,uv);
    vec4 tex_c2 = texture(tex2,uv);
    vec4 tex_c3 = texture(tex3,uv);

    if( tex_c1 == tex_c2 && tex_c2 == tex_c3 && tex_c1 == tex_c3 && _Check1 == 1.0)
    {
        outColor = tex_c2;
        return;
    }

    outColor.rgb = clr0 * tex_c1.rgb + clr1 * tex_c2.rgb * float(_Check0) + clr2 * tex_c3.rgb;
    outColor.a = clamp(tex_c1.a*_S1 + tex_c2.a* float(_Check0) + tex_c3.a*_S1, 0, 1);
}
]==]
content = newFilter(content)

tex1 = fetchTex(0, time - (1.0/fps) * slider(0))
tex2 = PARAM0
tex3 = fetchTex(0, time + (1.0/fps) * slider(0))

setFilterUniform(content, "sampler2D", "tex1", tex1)
setFilterUniform(content, "sampler2D", "tex2", tex2)
setFilterUniform(content, "sampler2D", "tex3", tex3)
setFilterUniform(content, "vec3", "clr0", color(0))
setFilterUniform(content, "vec3", "clr1", color(1))
setFilterUniform(content, "vec3", "clr2", color(2))
setFilterUniform(content, "float", "_S1", slider(1))
setFilterUniform(content, "float", "_Check0", checkbox(0) and 1.0 or 0.0)
setFilterUniform(content, "float", "_Check1", checkbox(1) and 1.0 or 0.0)

runFilter(content)