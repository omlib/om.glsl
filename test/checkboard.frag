#define SHADER_NAME Checkboard

varying vec2 vUv;

uniform int repeat;
uniform vec3 colorA;
uniform vec3 colorB;

void main() {

    vec2 pos = vUv / (1.0 / repeat);
    vec3 color;

    if( fract( pos.x ) < 0.5 ) {
        if( fract( pos.y ) < 0.5 ) {
            color = colorA;
        } else {
            color = colorB;
        }
    } else {
        if( fract( pos.y ) < 0.5 ) {
            color = colorB;
        } else {
            color = colorA;
        }
    }

    gl_FragColor = vec4( color, 1.0 );
}
