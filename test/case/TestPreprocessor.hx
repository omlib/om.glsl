
import js.node.Fs;
import om.glsl.Preprocessor;

class TestPreprocessor extends haxe.unit.TestCase {

	public function test() {

		var src = '#define HELLO_WORLD';
		var p = Preprocessor.parse( src );
		assertEquals( 'HELLO_WORLD', p.name );
		assertEquals( null, p.args );
		assertEquals( '', p.value );
		assertEquals( src, p.toString() );

		var src = '#define SHADER_NAME Checkboard';
		var p = Preprocessor.parse( src );
		assertEquals( 'SHADER_NAME', p.name );
		assertEquals( null, p.args );
		assertEquals( 'Checkboard', p.value );
		assertEquals( src, p.toString() );

		//TODO
		/*
		var src = '#define LOREM_IPSUM() a';
		var p = Lexer.parsePreprocessor( src );
		assertEquals( 'LOREM_IPSUM', p.name );
		trace(p.args.length);
		//assertEquals( 0, p.args.length );
		assertEquals( 'a', p.value );
		*/

		var src = '#define BOGAN_IPSUM(a) (a * 0.5 + 0.5)';
		var p = Preprocessor.parse( src );
		assertEquals( 'BOGAN_IPSUM', p.name );
		assertEquals( 1, p.args.length );
		assertEquals( 'a', p.args[0] );
		assertEquals( '(a * 0.5 + 0.5)', p.value );
		assertEquals( src, p.toString() );

		var src = '#define SOME_OTHERS(a,b) (a * 0.5 + b)';
		var p = Preprocessor.parse( src );
		assertEquals( 'SOME_OTHERS', p.name );
		assertEquals( 2, p.args.length );
		assertEquals( 'a', p.args[0] );
		assertEquals( 'b', p.args[1] );
		assertEquals( '(a * 0.5 + b)', p.value );
		assertEquals( src, p.toString() );
	}

}
