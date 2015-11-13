package om.glsl;

using StringTools;

class Preprocessor {

    public var name : String;
    public var args : Array<String>;
    public var value : String;

    public function new( name : String, ?args : Array<String>, ?value : String ) {
        this.name = name;
        this.args = args;
        this.value = value;
    }

    public function toString() : String {
        var buf = new StringBuf();
        buf.add( '#define ' );
        buf.add( name );
        if( args != null && args.length > 0 ) {
            buf.add( '(' );
            buf.add( args.join(',') );
            buf.add( ')' );
        }
        if( value != null && value.length > 0 ) {
            buf.add( ' ' );
            buf.add( value );
        }
        return buf.toString();
    }

    public static function parse( str : String ) : Preprocessor {

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
            return new Preprocessor( name, value );

        } else {
            var content = split.slice(1).join(' ').trim();
            var argsStart : Int = null;
            var argsEnd : Int = null;
            for( i in 0...content.length ) {
                switch content.charAt(i) {
                case '(': argsStart = i;
                case ')': argsEnd = i;
                case ' ','\t': if( argsEnd != null )
                    break;
                }
            }
            return new Preprocessor(
                content.substr( 0, argsStart ),
                content.substring( argsStart + 1, argsEnd ).split(',').map( StringTools.trim ),
                content.substr( argsEnd+1 ).trim()
            );
        }
    }
}
