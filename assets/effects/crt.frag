#version 130

uniform sampler2D texture;
uniform vec2 resolution;
uniform float time;

#define distortion 0.2

vec2 RadialDistortion(vec2 coord) {
  vec2 cc = coord - vec2(0.5);
  float dist = dot(cc, cc) * distortion;
  return coord + cc * (1.0 - dist) * dist;
}

void main() {
  vec2 texCoord = vec2(gl_TexCoord[0]);
  vec4 pixel = texture2D(texture, RadialDistortion(texCoord));
  vec4 intensity;

  if (fract(gl_FragCoord.y * (0.5 * 4.0 / 3.0)) > 0.5) {
    intensity = vec4(0);
  } else {
    intensity = smoothstep(0.4, 0.8, pixel) + normalize(pixel);
  }

  gl_FragColor = gl_Color * intensity;
}

