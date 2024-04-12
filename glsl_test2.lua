glsl([==[
void main(){
    outColor = vec4(uv,sin(time*10)/2+.5,1);
}
]==])
