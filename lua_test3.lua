version3()
local glsl_folder = [==[E:\zzz\pw folder]==]
local filename = 
"sincurve2.shader"
local file = io.open( glsl_folder .. "\\" .. filename,"r")
content = file:read("*all")
content2 = newFilter(content)

setFilterUniform(content2, "sampler2D", "_NoiseTex", PARAM0)
setFilterUniform(content2, "float", "_Cnf", slider(0))
setFilterUniform(content2, "float", "_C1h", point3d(0)[0])
setFilterUniform(content2, "float", "_C1r", point3d(0)[1])
setFilterUniform(content2, "float", "_C1s", point3d(0)[2])
setFilterUniform(content2, "float", "_C1spd", point3d(1)[0])
setFilterUniform(content2, "float", "_C1ost", point3d(1)[2])

setFilterUniform(content2, "float", "_C2h", point3d(2)[0])
setFilterUniform(content2, "float", "_C2r", point3d(2)[1])
setFilterUniform(content2, "float", "_C2s", point3d(2)[2])
setFilterUniform(content2, "float", "_C2spd", point3d(3)[0])
setFilterUniform(content2, "float", "_C2ost", point3d(3)[2])

setFilterUniform(content2, "vec4", "_LineColor", color(0),slider(1))
setFilterUniform(content2, "float", "time", time)
runFilter(content2)