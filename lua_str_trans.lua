-- version3()
local glsl_folder = [==[E:\zzz\pw folder]==]
local filename = 
"glsl_test4.shader"
local file = io.open( glsl_folder .. "\\" .. filename,"r")
markvalue_replace_on = 1

-- 替换用字符串表
local str_table = {
    {"_S(%d+)", "_PixelsWorld_slider[%1]"},
    {"_Ang(%d+)", "_PixelsWorld_angle[%1]"},
    {"_Check(%d+)", "_PixelsWorld_checkbox[%1]"},
    {"_Pt(%d+)", "_PixelsWorld_point[%1]"},
    {"_3DPt(%d+)", "_PixelsWorld_point3d[%1]"},
    {"_Clr(%d+)", "_PixelsWorld_color[%1]"},
    {"_inLayer", "_PixelsWorld_inLayer"}
}

local line_mark = {"//pwt", "//pwde"}

function str_trans(input, str_table, line_mark)
    -- 将输入字符串按行分割成表格
    local lines = {}
    for line in input:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    local filtered_lines = {}
    
    -- 逐行处理
    for i, line in ipairs(lines) do
        -- 处理带有//pwt注释的行，替换_S+数字变量
        if (markvalue_replace_on == 1) or line:find(line_mark[1]) then
            for j, element in ipairs(str_table) do
                line = line:gsub(element[1], element[2])
            end
        end
        lines[i] = line
        -- 删除带有//pwde注释的行
        if not line:find(line_mark[2]) then
            table.insert(filtered_lines, line)
        end
    end
    
    -- 构建最终字符串
    output = table.concat(filtered_lines, "\n")
    return output
end

if file then
    local content = file:read("*all")
    file:close()
    -- 输入的字符串
    shadertoy_code = str_trans(content, str_table, line_mark)
    -- print(shadertoy_code)
    runFilter(shadertoy_code)
else
    print("无法打开文件")
end