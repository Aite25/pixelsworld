uniform float _S0;
uniform float _S1;
uniform vec3 _Clr0;
uniform vec3 _Clr1;
uniform vec3 _Clr2;
uniform vec3 _Clr3;
uniform vec3 _Clr4;
uniform vec3 _Clr5;
uniform vec3 _Clr6;
uniform vec3 _Clr7;
uniform vec3 _Clr8;
uniform vec3 _Clr9;
uniform sampler2D inLayer;
uniform float _Checkbox0;
uniform float _Checkbox1;

vec3 clrMap(float map_value)
{
    if(_Checkbox1 == 1.0 && map_value == 1.0)
    {
        return vec3(1.0,1.0,1.0);
    }else if(_Checkbox1 == 1.0 && map_value == 0.0)
    {
        return vec3(0.0,0.0,0.0);
    }
    // 彩带颜色数量
    int numColors = int(floor(_S1)); // 可根据需要修改
    
    // 计算彩带颜色的索引
    float colorIndex = map_value * float(numColors - 1);
    int index1 = int(colorIndex);
    int index2 = min(index1 + 1, numColors - 1);
    
    // 计算补间系数
    float t = fract(colorIndex);
    float smoothT = smoothstep(0.0, 1.0, t);
    
    // 定义彩带颜色
    vec3 colors[10];
    colors[0] = _Clr0;
    colors[1] = _Clr1;
    colors[2] = _Clr2;
    colors[3] = _Clr3;
    colors[4] = _Clr4;
    colors[5] = _Clr5;
    colors[6] = _Clr6;
    colors[7] = _Clr7;
    colors[8] = _Clr8;
    colors[9] = _Clr9;
    
    // 使用smoothstep函数进行补间
    vec3 output_clr;
    output_clr.rgb = mix(colors[index1], colors[index2], smoothT);
    return output_clr;
}

void main()
{
    vec4 clr = texture(inLayer,uv);
    float luminance = dot(clr.rgb, vec3(0.2126, 0.7152, 0.0722));
    float average_clr = (clr.r + clr.g + clr.b)/3.0;
    float mapvalue;
    if(_Checkbox0 == 0.0)
    {
        mapvalue = luminance;
    }else{
        mapvalue = average_clr;
    }
    vec3 trans_clr = clrMap(mapvalue).rgb;

    // outColor = vec4(line,0.3,0.5,1.0);
    outColor.rgb = mix( trans_clr, clr.rgb, 1-clamp(_S0,0,1) );
    outColor.a = clr.a;
}
