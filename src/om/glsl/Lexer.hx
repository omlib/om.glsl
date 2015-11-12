package om.glsl;

using StringTools;

enum TokenType {
    block_comment;
    line_comment;
    preprocessor;
    operator;
    integer;
    float;
    ident;
    builtin;
    keyword;
    whitespace;
    //hex;
    //eof;
}

typedef Token = {
    var type : TokenType;
    var data : String;
    var position : Int;
    var line : Int;
    var column : Int;
}

typedef PreprocessorStatement = {
    var name : String;
    @:optional var args : Array<String>;
    var value : String;
    //var index : Int;
    //var token : Int;
}

private enum Mode {
    MNormal;
    MPreprocessor;
    MBlockComment;
    MLineComment;
    MWhitespace;
    MInteger;
    MFloat;
    MHex;
    MOperator;
    MToken;
    MIdent;
    MBuiltin;
    MKeyword;
}

class Lexer {

    public static var LITERALS(default,null) = ['precision', 'highp', 'mediump', 'lowp', 'attribute', 'const', 'uniform', 'varying', 'break', 'continue', 'do', 'for', 'while', 'if', 'else', 'in', 'out', 'inout', 'float', 'int', 'void', 'bool', 'true', 'false', 'discard', 'return', 'mat2', 'mat3', 'mat4', 'vec2', 'vec3', 'vec4', 'ivec2', 'ivec3', 'ivec4', 'bvec2', 'bvec3', 'bvec4', 'sampler1D', 'sampler2D', 'sampler3D', 'samplerCube', 'sampler1DShadow', 'sampler2DShadow', 'struct', 'asm', 'class', 'union', 'enum', 'typedef', 'template', 'this', 'packed', 'goto', 'switch', 'default', 'inline', 'noinline', 'volatile', 'public', 'static', 'extern', 'external', 'interface', 'long', 'short', 'double', 'half', 'fixed', 'unsigned', 'input', 'output', 'hvec2', 'hvec3', 'hvec4', 'dvec2', 'dvec3', 'dvec4', 'fvec2', 'fvec3', 'fvec4', 'sampler2DRect', 'sampler3DRect', 'sampler2DRectShadow', 'sizeof', 'cast', 'namespace', 'using'];
    public static var BUILTINS(default,null) = ['abs', 'acos', 'all', 'any', 'asin', 'atan', 'ceil', 'clamp', 'cos', 'cross', 'dFdx', 'dFdy', 'degrees', 'distance', 'dot', 'equal', 'exp', 'exp2', 'faceforward', 'floor', 'fract', 'gl_BackColor', 'gl_BackLightModelProduct', 'gl_BackLightProduct', 'gl_BackMaterial', 'gl_BackSecondaryColor', 'gl_ClipPlane', 'gl_ClipVertex', 'gl_Color', 'gl_DepthRange', 'gl_DepthRangeParameters', 'gl_EyePlaneQ', 'gl_EyePlaneR', 'gl_EyePlaneS', 'gl_EyePlaneT', 'gl_Fog', 'gl_FogCoord', 'gl_FogFragCoord', 'gl_FogParameters', 'gl_FragColor', 'gl_FragCoord', 'gl_FragData', 'gl_FragDepth', 'gl_FrontColor', 'gl_FrontFacing', 'gl_FrontLightModelProduct', 'gl_FrontLightProduct', 'gl_FrontMaterial', 'gl_FrontSecondaryColor', 'gl_LightModel', 'gl_LightModelParameters', 'gl_LightModelProducts', 'gl_LightProducts', 'gl_LightSource', 'gl_LightSourceParameters', 'gl_MaterialParameters', 'gl_MaxClipPlanes', 'gl_MaxCombinedTextureImageUnits', 'gl_MaxDrawBuffers', 'gl_MaxFragmentUniformComponents', 'gl_MaxLights', 'gl_MaxTextureCoords', 'gl_MaxTextureImageUnits', 'gl_MaxTextureUnits', 'gl_MaxVaryingFloats', 'gl_MaxVertexAttribs', 'gl_MaxVertexTextureImageUnits', 'gl_MaxVertexUniformComponents', 'gl_ModelViewMatrix', 'gl_ModelViewMatrixInverse', 'gl_ModelViewMatrixInverseTranspose', 'gl_ModelViewMatrixTranspose', 'gl_ModelViewProjectionMatrix', 'gl_ModelViewProjectionMatrixInverse', 'gl_ModelViewProjectionMatrixInverseTranspose', 'gl_ModelViewProjectionMatrixTranspose', 'gl_MultiTexCoord0', 'gl_MultiTexCoord1', 'gl_MultiTexCoord2', 'gl_MultiTexCoord3', 'gl_MultiTexCoord4', 'gl_MultiTexCoord5', 'gl_MultiTexCoord6', 'gl_MultiTexCoord7', 'gl_Normal', 'gl_NormalMatrix', 'gl_NormalScale', 'gl_ObjectPlaneQ', 'gl_ObjectPlaneR', 'gl_ObjectPlaneS', 'gl_ObjectPlaneT', 'gl_Point', 'gl_PointCoord', 'gl_PointParameters', 'gl_PointSize', 'gl_Position', 'gl_ProjectionMatrix', 'gl_ProjectionMatrixInverse', 'gl_ProjectionMatrixInverseTranspose', 'gl_ProjectionMatrixTranspose', 'gl_SecondaryColor', 'gl_TexCoord', 'gl_TextureEnvColor', 'gl_TextureMatrix', 'gl_TextureMatrixInverse', 'gl_TextureMatrixInverseTranspose', 'gl_TextureMatrixTranspose', 'gl_Vertex', 'greaterThan', 'greaterThanEqual', 'inversesqrt', 'length', 'lessThan', 'lessThanEqual', 'log', 'log2', 'matrixCompMult', 'max', 'min', 'mix', 'mod', 'normalize', 'not', 'notEqual', 'pow', 'radians', 'reflect', 'refract', 'sign', 'sin', 'smoothstep', 'sqrt', 'step', 'tan', 'texture2D', 'texture2DLod', 'texture2DProj', 'texture2DProjLod', 'textureCube', 'textureCubeLod' ];
    public static var OPERATORS(default,null) = ['<<=', '>>=', '++', '--', '<<', '>>', '<=', '>=', '==', '!=', '&&', '||', '+=', '-=', '*=', '/=', '%=', '&=', '^^', '^=', '|=', '(', ')', '[', ']', '.', '!', '~', '*', '/', '%', '+', '-', '<', '>', '&', '^', '|', '?', ':', '=', ',', ';', '{', '}' ];

    var input : String;
    var len : Int;
    var i : Int;
    var start : Int;
    var total : Int;
    var c : String;
    var last : String;
    var mode : Mode;
    var content : Array<String>;
    var line : Int;
    var col : Int;
    var tokens : Array<Token>;

    public function new() {
    }

    public function tokenize( src : String ) : Array<Token> {

        input = src;
        i = start = total = col = 0;
        line = 0;
        len = src.length;
        mode = MNormal;
        content = [];
        tokens = [];

        var lastIndex = 0;

        while( i < len ) {

            c = input.charAt(i);
            lastIndex = i;

            i = switch mode {
            case MBlockComment: readBlockComment();
            case MLineComment: readLineComment();
            case MPreprocessor: readPreprocessor();
            case MOperator: readOperator();
            case MInteger: readInteger();
            case MHex: readHex();
            case MFloat: readFloat();
            case MToken: readToken();
            case MWhitespace: readWhitespace();
            case MNormal: readNormal();
            default:
                throw 'invalid mode: '+mode;
            }

            if( lastIndex != i ) {
                switch input.charAt(i) {
                case '\n':
                    col = 0;
                    ++line;
                default: ++col;
                }
            }
        }

        total += i;
        input = input.substr(i);

        return tokens;
    }

    function readNormal() : Int {

        if( content.length > 0 ) content = [];

        if( last == "/" && c == "*" ) {
            start = total + i - 1;
            mode = MBlockComment;
            last = c;
            return i + 1;
        }
        if( last == "/" && c == "/" ) {
            start = total + i - 1;
            mode = MLineComment;
            last = c;
            return i + 1;
        }
        if( c == '#' ) {
            mode = MPreprocessor;
            start = total + i;
            return i;
        }
        if( ~/\s/.match( c ) ) {
            mode = MWhitespace;
            start = total + i;
            return i;
        }

        start = total + i;
        mode = ~/\d/.match(c) ? MInteger : ~/[^\w_]/.match(c) ? MOperator : MToken;

        return i;
    }

    function readWhitespace() : Int {
        if( ~/[^\s]/g.match(c) ) {
            token( content.join( '' ) );
            mode = MNormal;
            return i;
        }
        return nextChar();
    }

    function readPreprocessor() : Int {
        if( c == '\n' && last != '\\' ) {
            token( content.join( '' ) );
            mode = MNormal;
            return i;
        }
        return nextChar();
    }

    function readBlockComment() : Int {
        if( c == '/' && last == '*' ) {
            content.push( c );
            token( content.join( '' ) );
            mode = MNormal;
            return i + 1;
        }
        return nextChar();
    }

    function readLineComment() : Int {
        return readPreprocessor();
    }

    function readInteger() : Int {
        if( c == '.' ) {
            content.push(c);
            mode = MFloat;
            last = c;
            return i + 1;
        }
        if( ~/[eE]/.match(c) ) {
            content.push(c);
            mode = MFloat;
            last = c;
            return i + 1;
        }
        if( c == 'x' && content.length == 1 && content[0] == '0' ) {
            mode = MHex;
            content.push(c);
            last = c;
            return i + 1;
        }

        if( ~/[^\d]/.match(c) ) {
            token(content.join('') );
            mode = MNormal;
            return i;
        }
        return nextChar();
    }

    function readHex() : Int {
        if( ~/[^a-fA-F0-9]/.match(c) ) {
            token( content.join('') );
            mode = MNormal;
            return i;
        }
        return nextChar();
    }

    function readFloat() : Int {
        if( c == 'f' ) {
            content.push(c);
            last = c;
            i += 1;
        }
        if( ~/[eE]/.match(c) ) {
            content.push(c);
            last = c;
            return i + 1;
        }
        if( ~/[^\d]/.match(c) ) {
            token( content.join( '' ) );
            mode = MNormal;
            return i;
        }
        return nextChar();
    }

    function readOperator() : Int {
        if( last == '.' && ~/\d/.match(c) ) {
            mode = MFloat;
            return i;
        }
        if( last == '/' && c == '*' ) {
            mode = MBlockComment;
            return i;
        }
        if( last == '/' && c == '/' ) {
            mode = MLineComment;
            return i;
        }
        if( c == '.' && content.length > 0 ) {
            while( determine_operator( content ) > 0 ) {}
            mode = MFloat;
            return i;
        }
        if( c == ';' || c == ')' || c == '(' ) {
            if( content.length > 0 ) {
                while( determine_operator( content ) > 0 ) {}
            }
            token(c);
            mode = MNormal;
            return i + 1;
        }
        var is_composite_operator = content.length == 2 && c != '=';
        if( ~/[\w_\d\s]/.match(c) || is_composite_operator ) {
            while( determine_operator( content ) > 0 ) {}
            mode = MNormal;
            return i;
        }
        return nextChar();
    }

    function readToken() : Int {
        if( ~/[^\d\w_]/.match(c) ) {
            var contentstr = content.join( '' );
            if( LITERALS.indexOf( contentstr ) > -1 ) {
                mode = MKeyword;
            } else if( BUILTINS.indexOf( contentstr ) > -1 ) {
                mode = MBuiltin;
            } else {
                mode = MIdent;
            }
            //token( content.join( '' ) );
            token( contentstr );
            mode = MNormal;
            return i;
        }
        return nextChar();
    }

    function determine_operator( buf : Array<String> ) {

        var j, idx = 0;
        var res : String = null;

        do {

            idx = OPERATORS.indexOf( buf.slice( 0, buf.length + j ).join( '' ) );
            res = OPERATORS[idx];

            if( idx == -1 ) {
                if( j-- + buf.length > 0 )
                    continue;
                res = buf.slice(0, 1).join( '' );
            }

            token( res );

            start += res.length;
            content = content.slice( res.length );
            return content.length;

        } while(true);

        return 0;
    }

    function nextChar() : Int {
        content.push(c);
        last = c;
        return i + 1;
    }

    function token( data : String ) {
        if( data.length > 0 ) {
            tokens.push({
                type: getTokenType( mode ),
                data: data,
                position: start,
                line: line,
                column: col
            });
        }
    }

    static function getTokenType( mode : Mode ) : TokenType {
        return switch mode {
        case MBlockComment: block_comment;
        case MLineComment: line_comment;
        case MPreprocessor: preprocessor;
        case MOperator: operator;
        case MInteger, MHex: integer;
        case MFloat: float;
        case MWhitespace: whitespace;
        case MKeyword: keyword;
        case MIdent: ident;
        case MBuiltin: builtin;
        case MNormal,MToken: null;
        }
    }

    public static inline function fromSource( src : String ) : Array<Token> {
        return new om.glsl.Lexer().tokenize( src );
    }

    public static function toSource( tokens : Array<Token> ) : String {
        var src = new StringBuf();
        for( token in tokens ) src.add( token.data );
        return src.toString();
    }

    public static function parsePreprocessor( str : String ) : PreprocessorStatement {

        var split = ~/\s+/.split( str.trim() );

        if( split[0] != '#define' )
            return throw 'invalid preprocessor statement';

        if( split[1].indexOf( '(' ) == -1 ) {
            var name : String = null;
            var value : String = null;
            var expr = ~/^([a-zA-Z_]+)(\s+(.+))$/;
            if( expr.match( split[1]) ) {
                name = expr.matched(1);
                value = expr.matched(3);
            } else {
                name = split[1];
                value = split.slice(2).join(' ').trim();
            }
            return {
                name: name,
                args: null,
                value: value
            };

        } else {
            var content = split.slice(1).join(' ').trim();
            var argsStart : Int = null;
            var argsEnd : Int = null;
            for( i in 0...content.length ) {
                var char = content.charAt(i);
                switch char {
                case '(': argsStart = i;
                case ')': argsEnd = i;
                case ' ','\t': if( argsEnd != null )
                    break;
                }
            }
            var args = content.substring( argsStart + 1, argsEnd ).split(',');
            return {
                name: content.substr( 0, argsStart ),
                value: content.substr( argsEnd+1 ).trim(),
                args: args.map( StringTools.trim ),
            }
        }
    }
}
