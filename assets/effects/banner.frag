#version 130

uniform sampler2D texture;
uniform vec4 color;

void main() {
  vec4 fragcolor = texture2D(texture, gl_TexCoord[0].xy) * color;
  
  vec3 lum = vec3(0.299, 0.587, 0.114);
  fragcolor = vec4(vec3(dot(fragcolor.rgb, lum)), fragcolor.a);
  fragcolor = vec4(0, fragcolor.g * 0.69, 0, fragcolor.a);

  gl_FragColor = fragcolor;
}

