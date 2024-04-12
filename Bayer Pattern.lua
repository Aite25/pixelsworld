-- version3()
--[[
Globalgrid - slider(0):1 -> globalgrid size of units
Subdivs - slider(1):4 -> subdivs of units, like threshold of wipe
Bayer Pattern Pixels by Aite25
--]]
content = [==[
uniform float _S0;
uniform float _S1;
uniform sampler2D inLayer;

float bayer(vec2 screenPos, float globalgrid, int subdivs, float contrast){
    if(contrast == 0)
    {
        return 0.0;
    }else if(contrast == 1)
    {
        return 1.0;
    }
    vec2 baseuv = screenPos;
    int sizex;
    int sizey;
    sizex = int(pow(2.,float(subdivs)));
    sizey = sizex;    
    vec2 size = vec2(sizex,sizey);
    
    // fine grid
    vec2 seed = floor(baseuv/globalgrid);

    // bayer grid
    ivec2 bayer_grid = ivec2(fract(seed/size)*size);
    int val = 0;
    
    // basic 2x2 bayer pattern
    int pattern[] = int[4](0,2,3,1);

    int curdiv = sizex/2;
    int scale = 1;

    for(int i=0;i<subdivs;++i) {
    
        vec2 sseed = floor(seed/float(curdiv*2));
        // bayer pattern
        ivec2 pos = (bayer_grid/curdiv)%2;
        int id = pos.x+pos.y*2;
        val += pattern[id%4] * scale;
        
        curdiv /= 2;
        scale *= 4;
    }
    float perc = float(val)/(size.x*size.y);   
    return step(perc,contrast);
}

void main(){
    vec4 screenPos = gl_FragCoord;
    vec4 picclr = texture(inLayer,uv);
    vec4 bayer_clr;
    float globalgrid = _S0;
    int subdivs = int(_S1);
    bayer_clr.r = bayer(screenPos.xy, globalgrid, subdivs, picclr.r);
    bayer_clr.g = bayer(screenPos.xy, globalgrid, subdivs, picclr.g);
    bayer_clr.b = bayer(screenPos.xy, globalgrid, subdivs, picclr.b);
    bayer_clr.a = bayer(screenPos.xy, globalgrid, subdivs, picclr.a);
    outColor = bayer_clr;
}
]==]
content = newFilter(content)

setFilterUniform(content, "sampler2D", "inLayer", INPUT)
setFilterUniform(content, "float", "_S0", slider(0))
setFilterUniform(content, "float", "_S1", slider(1))
runFilter(content)