
#ifdef GL_ES
precision ::precision:: float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;

uniform float numRings;
uniform float speed;

float rings( vec2 pos ) {
    return sin( length( pos ) * numRings - time * speed );
}

void main() {
    vec2 pos = ( gl_FragCoord.xy * 2.0 - resolution ) / resolution.y;
    float r = sin( length( pos ) * numRings - time * speed );
    gl_FragColor = vec4( r );
}
