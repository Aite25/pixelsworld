-- 输入的字符串
local input = [[
#define _S0 0.5//pwde
float line_pos = _S0;//pwt
#define _S1 0.3//pwt
float another_pos = _S1;//pwde
#define PI 3.1415926535
float drawline(float value,float pos,float width)
{
    float line = smoothstep(pos - width,pos + width,value);

    return line;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 screenPos = fragCoord;
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    float line = drawline(uv[0],sin(fract(line_pos)* PI * 2.0)*0.5 + 0.5,0.001);
    fragColor = vec4(line,0.3,0.5,1.0);
}
]]

-- 将输入字符串按行分割成表格
local lines = {}
for line in input:gmatch("[^\r\n]+") do
    table.insert(lines, line)
end

-- 删除带有//pwde注释的行
local filtered_lines = {}
for _, line in ipairs(lines) do
    if not line:find("//pwde") then
        table.insert(filtered_lines, line)
    end
end

-- 构建最终字符串
local output = table.concat(filtered_lines, "\n")

print("________________\n" .. output) -- 输出处理后的字符串
