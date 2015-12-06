
import js.node.Fs;
import om.glsl.Tokenizer;

class TestTokenizer extends haxe.unit.TestCase {

	public function test_tokenize_checkboard() {

		var src = Fs.readFileSync( 'checkboard.frag' ).toString();

        var tokenizer = new om.glsl.Tokenizer();
        var tokens = tokenizer.write( src );

        //for( token in tokens ) trace(token);
        //trace( Lexer.toSource( tokens, true ) );
        //trace( tokens[tokens.length-1] );
        //assertEquals( src, Lexer.toSource( tokens ) );

        //TODO
        //assertTokenEquals( { type:preprocessor, data:'#define SHADER_NAME Checkboard', position:0, line:1, column:0 }, tokens[0] );

		assertEquals( preprocessor, tokens[0].type );
        assertEquals( '#define SHADER_NAME Checkboard', tokens[0].data );
        assertEquals( 0, tokens[0].position );
        assertEquals( 1, tokens[0].line );
        assertEquals( 30, tokens[0].column );

		assertEquals( whitespace, tokens[1].type );
        assertEquals( '\n\n', tokens[1].data );
        assertEquals( 30, tokens[1].position );
        assertEquals( 3, tokens[1].line );
        assertEquals( 0, tokens[1].column );

		assertEquals( keyword, tokens[2].type );
        assertEquals( 'varying', tokens[2].data );
        assertEquals( 32, tokens[2].position );
        assertEquals( 3, tokens[2].line );
        assertEquals( 7, tokens[2].column );

		//.....
	}

	/*
	public function test_tokenize_fixture() {

		var src = Fs.readFileSync( 'fixture.glsl' ).toString();

		var tokens = Lexer.fromSource( src );

		//for( token in tokens ) trace(token);
		//trace( Lexer.toSource( tokens ) );
		//trace( tokens[tokens.length-1] );
		//assertEquals( src, Lexer.toSource( tokens ) );

		//TODO
		assertTokenEquals( { type:whitespace, data:'\n', position:0, line:2, column:0 }, tokens[0] );

	}
	*/
}
