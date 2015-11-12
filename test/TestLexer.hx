
import om.glsl.Lexer;

class TestLexer extends haxe.unit.TestCase {

	public function test_build() {

        var src = '#define SHADER_NAME Checkboard

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
}';

        var lexer = new om.glsl.Lexer();
        var tokens = lexer.tokenize( src );

        //for( token in tokens ) trace(token);
        //trace( Lexer.toSource( tokens ) );
        //trace( tokens[tokens.length-1] );

        //assertEquals( src, Lexer.toSource( tokens ) );

        //TODO
        assertTokenEquals( { type:preprocessor, data:'#define SHADER_NAME Checkboard', position:0, line:1, column:0 }, tokens[0] );
        //assertTokenEquals( { type:whitespace, data:'\n', position:30, line:3, column:9 }, tokens[1] );
        //assertTokenEquals( { type:keyword, data:'varying', position:0, line:2, column:0 }, tokens[1] );
	}

	public function test_preprocessor() {

		var src = '#define HELLO_WORLD';
		var p = Lexer.parsePreprocessor( src );
		assertEquals( 'HELLO_WORLD', p.name );
		assertEquals( null, p.args );
		assertEquals( '', p.value );

		var src = '#define SHADER_NAME Checkboard';
		var p = Lexer.parsePreprocessor( src );
		assertEquals( 'SHADER_NAME', p.name );
		assertEquals( null, p.args );
		assertEquals( 'Checkboard', p.value );

		/*
		var src = '#define LOREM_IPSUM() a';
		var p = Lexer.parsePreprocessor( src );
		assertEquals( 'LOREM_IPSUM', p.name );
		//TODO
		trace(p.args.length);
		//assertEquals( 0, p.args.length );
		assertEquals( 'a', p.value );
		*/

		var src = '#define BOGAN_IPSUM(a) (a * 0.5 + 0.5)';
		var p = Lexer.parsePreprocessor( src );
		assertEquals( 'BOGAN_IPSUM', p.name );
		assertEquals( 1, p.args.length );
		assertEquals( 'a', p.args[0] );
		assertEquals( '(a * 0.5 + 0.5)', p.value );

		var src = '#define SOME_OTHERS(a, b) (a * 0.5 + b)';
		var p = Lexer.parsePreprocessor( src );
		assertEquals( 'SOME_OTHERS', p.name );
		assertEquals( 2, p.args.length );
		assertEquals( 'a', p.args[0] );
		assertEquals( 'b', p.args[1] );
		assertEquals( '(a * 0.5 + b)', p.value );
	}

    function assertTokenEquals( a : Token, b : Token ) {
        assertEquals( a.type, b.type );
        assertEquals( a.data, b.data );
        assertEquals( a.position, b.position );
        assertEquals( a.line, b.line );
        assertEquals( a.column, b.column );
    }

}
