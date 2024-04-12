-- version3()
local glsl_folder = [==[E:\zzz\pw folder]==]
local filename = 
"sincurve2.shader"
local file = io.open( glsl_folder .. "\\" .. filename,"r")
content = file:read("*all")
content = newFilter(content)
setFilterUniform(content, "vec3", "_Clr0", color(0))
setFilterUniform(content, "float", "_S0", slider(0))
-- setFilterUniform(content, "sampler2D", "inLayer", INPUT)
-- setFilterUniform(content, "float", "_S0", slider(0))
-- setFilterUniform(content, "float", "_S1", slider(1))
-- setFilterUniform(content, "vec3", "_Clr1", color(1))
-- setFilterUniform(content, "vec3", "_Clr2", color(2))
-- setFilterUniform(content, "vec3", "_Clr3", color(3))
-- setFilterUniform(content, "vec3", "_Clr4", color(4))
-- setFilterUniform(content, "vec3", "_Clr5", color(5))
-- setFilterUniform(content, "vec3", "_Clr6", color(6))
-- setFilterUniform(content, "vec3", "_Clr7", color(7))
-- setFilterUniform(content, "vec3", "_Clr8", color(8))
-- setFilterUniform(content, "vec3", "_Clr9", color(9))

-- setFilterUniform(content, "float", "_Checkbox0", checkbox(0) and 1.0 or 0.0)

runFilter(content)