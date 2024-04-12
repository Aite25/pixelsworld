
#define _S1 4//pwde
#define _inLayer iChannel0//pwde
#iChannel0 "file://pictest.png"//pwde

float bayer(vec2 screenPos, float globalgrid, int subdivs, float contrast){
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 screenPos = fragCoord;
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec4 picclr = texture(_inLayer,uv);
    vec3 bayer_clr;
    #define _S0 1.0//pwde
    float globalgrid = _S0;//pwt
    int subdivs = int(_S1);//pwt
    bayer_clr.r = bayer(screenPos, globalgrid, subdivs, picclr.r);
    bayer_clr.g = bayer(screenPos, globalgrid, subdivs, picclr.g);
    bayer_clr.b = bayer(screenPos, globalgrid, subdivs, picclr.b);

    fragColor.rgb = bayer_clr.rgb;
    fragColor.a = 1.0;
}