--version3()
local glsl_folder = [==[E:\zzz\pw folder]==]
local file = io.open( glsl_folder .. "\\" .. "glsl_test4.shader", "r")

if file then
    local content = file:read("*all")
    file:close()
    print("________________Code_Start________________\n" .. content .. "\n________________Code_End________________")
else
    print("无法打开文件")
end
