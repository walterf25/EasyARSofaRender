attribute vec3 aPosition;

uniform mat4 uProjectionMatrix;
uniform mat4 uModelMatrix;

void main() {
    gl_Position = uProjectionMatrix * uModelMatrix * vec4(aPosition, 1.0);
}