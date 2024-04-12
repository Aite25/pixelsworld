#define PI 3.14159

uniform vec4 _LineColor;
uniform float _Cnf;

uniform float _C1h;
uniform float _C1r;
uniform float _C1s;
uniform float _C1spd;
uniform float _C1ost;

uniform float _C2h;
uniform float _C2r;
uniform float _C2s;
uniform float _C2spd;
uniform float _C2ost;

uniform float time;
uniform vec2 _Time = vec2(time*0.5,time);
uniform sampler2D _NoiseTex;

float noisemap(vec2 x) {
    return texture(_NoiseTex, x).r;
}

float fit(float aa, float ba, float ca, float da, float ea) {
    float newa = (aa - ba) * (ea - da) / (ca - ba) + da;
    newa = clamp(newa, da, ea);
    return newa;
}

// vec3 ChangeHue(vec3 rgb, float hueDelta) {
//     vec3 hsv = RgbToHsv(rgb);
//     hsv.x += hueDelta;
//     hsv.x = fract(hsv.x); // Wrap hue value to the range [0, 1]
//     return HsvToRgb(hsv);
// }

float sin_cul(float u, float c_ratio, float c_spd, float c_height, float c_offset) {
    return sin(u * c_ratio * sin(2.0 * PI * _Time.x * 1.5) + 2.0 * PI * _Time.x * 4.0 * c_spd + c_offset) * 0.5 * c_height + 0.5;
}

float createCurve(vec2 inputUV, vec2 noiseUV, float noise_factor, float flowscale, float flowspeed, float sinvalue, float c_stroke) {
    float noisemask2 = noisemap(noiseUV * flowscale + flowspeed * _Time);
    float noisemask1 = noisemap(vec2(noiseUV.x + fract(_Time), noiseUV.y + fract(_Time)));
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
    // Define the base vector of the rhombus, in this case (width, height).
    vec2 baseVector = wh;

    // Calculate the signed distance to the rhombus.
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

//----------------------------
void main(){
    vec2 screenUV = uv;
    vec2 screenPos = gl_FragCoord;

    vec2 inputUV = uv;
    vec4 lineclr = _LineColor;

    //lineclr.rgb = ChangeHue(lineclr.rgb, sin(_Time.y) * 0.3);
    float sin1value = sin_cul(inputUV.x, _C1r, _C1spd, _C1h, 0.0 + _C1ost);
    float sin2value = sin_cul(inputUV.x, _C2r, _C2spd, _C2h, 5.0 + _C2ost);
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
    float width = 0.05 * _C1s;

    float factor1 = createCurve(vec2(inputUV.x, sin1value), vec2(inputUV.x, sin1value), noise_factor, 2.0, 0.2, sin1value, _C1s);
    float factor2 = createCurve(vec2(inputUV.x, sin2value), vec2(inputUV.x, sin2value), noise_factor, 0.7, 0.3, sin2value, _C2s);
    float pct1 = drawRhombus2(uv, vec2(fract(_Time.x * 2.6 + 0.0), sin1value), vec2(width, width * 0.3), factor1);
    float pct3 = drawRhombus2(uv, vec2(fract(_Time.x * 3.0 + 1.5), sin1value), vec2(width, width * 0.3), factor1);
    float pct2 = drawRhombus2(uv, vec2(fract(_Time.x * 3.0 + 0.8), sin2value), vec2(width, width * 0.3), factor2);
    float pct4 = drawRhombus2(uv, vec2(fract(_Time.x * 3.4 + 3.6), sin2value), vec2(width, width * 0.3), factor2);
    vec4 pctclr = (vec4(pct1, pct1, pct1, 1.0) + vec4(pct2, pct2, pct2, 1.0) + vec4(pct3, pct3, pct3, 1.0) + vec4(pct4, pct4, pct4, 1.0)) * lineclr;

    //outColor = finclr + pctclr;
    outColor = _LineColor;

}