#define _S0 0.5//pwde
float line_pos = _S0;//pwt
#define PI 3.1415926535
float drawline(float value,float pos,float width)
{
    float line = smoothstep(pos - width,pos + width,value);

    return line;
}

float stepline(float value,float pos)
{
    float line = step(value,pos);
    return line;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 screenPos = fragCoord;
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    float line = drawline(uv[0],sin(fract(line_pos)* PI * 2.0)*0.5 + 0.5,0.001);
    float line_a = step(uv[0],0.7);
    float line_b = step(0.5,uv[0]);
    // fragColor = vec4(line,0.3,0.5,1.0);
    fragColor = vec4(line_a * line_b,0.3,0.5,1.0);
}
