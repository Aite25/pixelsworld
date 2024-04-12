version3()
filterID = newFilter([[

    uniform float myfloat;
    uniform vec2 myvec;
    uniform mat3x2 mymat;
    uniform sampler2D mytex1;

    void main(){
        outColor = vec4(myfloat,myvec[0],mymat[0][1],1) + texture(mytex1,uv);
    }
]])



setFilterUniform(filterID, "float", "myfloat", math.sin(time)*0.5 + 0.5)

setFilterUniform(filterID, "vec2", "myvec", 1,2)

-- Column major, namely mymat[0][0]==1, mymat[0][1]==slider(0), mymat[0][2]==2, mymat[1][0]==3, ...
setFilterUniform(filterID, "mat3x2", "mymat", 1, slider(0), 2, 3, 4, 5)

-- Use INPUT texture as mytex1
setFilterUniform(filterID, "sampler2D", "mytex1", INPUT)

-- ** You can also set the texture you created as mytex1 **
-- myInputTexID = newTex(512,256)
-- setFilterUniform(filterID, "sampler2D", "mytex1", myInputTexID)

runFilter(filterID)
