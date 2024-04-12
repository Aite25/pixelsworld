#define PI 3.1415926535

vec4 _LineColor = vec4(0.69,0.93,1,1);
float _C1h = 0.2;
float _C1r = 4.2;
float _C1spd = 0.03;
float _C1s = 0.7;

float _C2h = 0.2;
float _C2r = 5.22;
float _C2spd = 0.02;
float _C2s = 0.6;

float _Cnf = 1.0;

float noisemap(vec2 x) {
    return texture(layer[0], x*0.1).x;
}

float fit(float aa, float ba, float ca, float da, float ea) {
    float newa = (aa - ba) * (ea - da) / (ca - ba) + da;
    newa = clamp(newa, da, ea);
    return newa;
}

vec3 hueRotate(vec3 color, float angle) {
    vec3 luminance = vec3(0.299, 0.587, 0.114);
    float luminanceDot = dot(color, luminance);
    vec3 perpendicular = color - luminanceDot * luminance;
    vec3 rotatedColor = cos(angle) * perpendicular + sin(angle) * cross(luminance, perpendicular) + luminanceDot * luminance;
    
    return rotatedColor;
}

float sin_cul(float u, float c_ratio, float c_spd, float c_height, float c_offset) {
    return sin(u * c_ratio * sin(time * 0.02 * PI * 2.0 * 1.5) + 
    time * 2.5 * PI * 2.0 * 4.0 * c_spd + c_offset) * 0.5 * c_height + 0.5;
}

float createCurve(vec2 inputUV, vec2 noiseUV, float noise_factor, float flowscale, float flowspeed, float sinvalue, float c_stroke) {
    float noisemask2 = noisemap(noiseUV * flowscale + flowspeed * time * 0.02 * fit(sin(time * 0.2 + flowspeed), -1.0, 1.0, 0.0, 1.0));
    float noisemask1 = noisemap(vec2(noiseUV.x + fit(sin(time * 0.3 + flowspeed), -1.0, 1.0, 0.0, 1.0), noiseUV.y) + fract(time * 0.2));
    float curve_mask = 0.0;

    float sin_gap = distance(sinvalue, inputUV.y);
    float c_thres = noisemask1 + noisemask2;
    c_thres = c_thres * c_stroke * noise_factor;
    if (sin_gap < c_thres) {
        curve_mask = (c_thres - sin_gap) * 90.0 * noisemask2;
    }
    return curve_mask;
}

float ndot(vec2 a, vec2 b) {
    return a.x * b.x - a.y * b.y;
}

float sdRhombus(vec2 p, vec2 b) {
    p = abs(p);
    float h = clamp(ndot(b - 2.0 * p, b) / dot(b, b), -1.0, 1.0);
    vec2 factor = vec2(1.0 - h, 1.0 + h);
    vec2 offset = 0.5 * b * factor;
    float d = length(p - offset);
    float signedDistance = d * sign(p.x * b.y + p.y * b.x - b.x * b.y);
    return signedDistance;
}

float drawRhombus(vec2 uv, vec2 wh, float factor) {
    vec2 baseVector = wh;
    float signedDist = sdRhombus(uv, baseVector);
    float rhombus = 1.0;
    if (signedDist < 0.0) {
        rhombus = abs(signedDist) * 90.0 * factor;
    } else {
        rhombus = 0.0;
    }
    return rhombus;
}

float drawRhombus2(vec2 uv, vec2 posuv, vec2 wh, float factor) {
    return drawRhombus(uv - posuv, wh, factor);
}

void main()
{
    vec4 positionSS = vec4(uv * 2.0 - 1.0, 0.0, 1.0);
    vec3 positionWS = positionSS.xyz / (positionSS.w + 0.00000000001);
    vec3 ndc = positionSS.xyz / (positionSS.w + 0.00000000001);
    vec2 screenUV = ndc.xy;
    vec2 screenPos = screenUV * resolution.xy;

    vec2 inputUV = uv;
    vec4 lineclr = _LineColor;
    lineclr.rgb = hueRotate(lineclr.rgb, sin(time * 2.0) * 0.3);
    float sin1value = sin_cul(inputUV.x, _C1r, _C1spd, _C1h, 0.0);
    float sin2value = sin_cul(inputUV.x, _C2r, _C2spd, _C2h, 5.0);
    float noise_factor = _Cnf * 0.01;

    float c1_mask = createCurve(inputUV, inputUV, noise_factor + 0.01, 1.0, 0.2, sin1value, _C1s);
    float c2_mask = createCurve(inputUV, inputUV, noise_factor + 0.01, 0.7, 0.3, sin2value, _C2s);
    vec4 c1_clr_r = createCurve(inputUV, vec2(inputUV.x - 0.01, inputUV.y), noise_factor, 2.0, 0.2, sin1value, _C1s) * vec4(1.0, 0.0, 0.0, 1.0) * lineclr;
    vec4 c1_clr_g = createCurve(inputUV, inputUV, noise_factor, 2.0, 0.2, sin1value, _C1s) * vec4(0.0, 1.0, 0.0, 1.0) * _LineColor;
    vec4 c1_clr_b = createCurve(inputUV, vec2(inputUV.x + 0.01, inputUV.y), noise_factor, 2.0, 0.2, sin1value, _C1s) * vec4(0.0, 0.0, 1.0, 1.0) * lineclr;
    vec4 c1_clr = c1_clr_r + c1_clr_g + c1_clr_b;
    vec4 c2_clr_r = createCurve(inputUV, vec2(inputUV.x - 0.01, inputUV.y), noise_factor, 2.5, 0.3, sin2value, _C2s) * vec4(1.0, 0.0, 0.0, 1.0) * lineclr;
    vec4 c2_clr_g = createCurve(inputUV, inputUV, noise_factor, 2.5, 0.3, sin2value, _C2s) * vec4(0.0, 1.0, 0.0, 1.0) * _LineColor;
    vec4 c2_clr_b = createCurve(inputUV, vec2(inputUV.x + 0.01, inputUV.y), noise_factor, 2.5, 0.3, sin2value, _C2s) * vec4(0.0, 0.0, 1.0, 1.0) * lineclr;
    vec4 c2_clr = c2_clr_r + c2_clr_g + c2_clr_b;
    
    vec4 finclr;
    finclr = c1_clr + c2_clr;
    finclr.rgb *= _LineColor.a * 2.2;
    finclr.a = clamp(finclr.a,0.0,1.0);
    vec2 setuv = uv;
    float width = 0.1 * _C1s;

    float factor1 = createCurve(vec2(inputUV.x, sin1value), vec2(inputUV.x, sin1value), noise_factor, 2.0, 0.2, sin1value, _C1s);
    float factor2 = createCurve(vec2(inputUV.x, sin2value), vec2(inputUV.x, sin2value), noise_factor, 0.7, 0.3, sin2value, _C2s);
    float pct1 = drawRhombus2(uv, vec2(fract(time * 0.1 * 3.0), sin1value), vec2(width, width * 0.3), factor1);
    float pct3 = drawRhombus2(uv, vec2(fract(time * 0.1 * 3.0 + 1.5), sin1value), vec2(width, width * 0.3), factor1);
    float pct2 = drawRhombus2(uv, vec2(fract(time * 0.1 * 3.0), sin2value), vec2(width, width * 0.3), factor2);
    float pct4 = drawRhombus2(uv, vec2(fract(time * 0.1 * 3.0 + 3.6), sin2value), vec2(width, width * 0.3), factor2);
    vec4 pctclr = (pct1 + pct2 + pct3 + pct4) * lineclr;
    
    outColor = finclr + pctclr;
}